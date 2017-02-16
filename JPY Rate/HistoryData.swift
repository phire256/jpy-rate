//
//  JpyData.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2016/2/12.
//  Copyright (c) 2016年 Yong Min Chen. All rights reserved.
//

import Foundation

class HistoryData: NSObject, URLSessionDataDelegate {
    
    // MARK:- store keys
    fileprivate let timeKey = "historytime"
    fileprivate let rateKey = "historyrate"
    
    fileprivate let userDefault = UserDefaults.standard
    fileprivate var data: NSMutableData? = nil
    
    fileprivate var connectionHandler: ((Bool) -> Void)? = nil
    
    // MARK:- private functions
    // TODO: make resetDatabase() private!
    func resetDatabase() {
    }
    
    fileprivate func isDataAlreadyExists(_ time: Int) -> Bool {
        let timeInteger = userDefault.integer(forKey: timeKey) as NSInteger
        if time == timeInteger {
            return true
        }
        return false
    }
    fileprivate func addRate(_ rate: NSArray, updateTime: Int) {
        userDefault.set(rate, forKey: rateKey)
        userDefault.set(updateTime, forKey: timeKey)
    }
    
    // MARK: - session data delegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.data == nil {
            self.data = (data as NSData).mutableCopy() as? NSMutableData
        } else {
            self.data?.append(data)
        }
        
        //print("didReceiveData")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (error != nil) {
            // fail
            //print("completeFail")
        } else {
            //print("completeSuccess")
            // success
            var hasItem = false
            let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: self.data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            
            // check error
            if (jsonResult["updateTime"] as! NSInteger == 0) {
                return
            }
            if (jsonResult["rates"] is NSNull) {
                return
            }
            
            // add item
            if !isDataAlreadyExists(jsonResult["updateTime"] as! NSInteger) {
                addRate(jsonResult["rates"] as! NSArray,
                        updateTime: jsonResult["updateTime"] as! NSInteger)
                
                // flag
                hasItem = true
            }
            
            // handler
            if (self.connectionHandler != nil) {
                self.connectionHandler!(hasItem)
                // discard handler
                self.connectionHandler = nil
            }
        }
    }

    // MARK:- public functions
    func updateData(_ handler: ((Bool) -> Void)?) {
        // handler
        self.connectionHandler = handler
        // connection
        let urlPath = ApiSite.historysite
        let url = URL(string: urlPath)
        let request = URLRequest(url: url!)
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request)
        
        // reset data
        self.data = nil
        
        // start task
        task.resume()
    }
    func getDataSize() -> NSInteger {
        //return min(tryGetShowSize(), tryGetDataSize())
        return 0
    }
    
    func getArray(_ numberOfItems:NSInteger) -> [Rate]? {
        if numberOfItems < 0 {
            return nil
        }
        
        var itemRequired = numberOfItems
        
        var jpyList = [Rate]()
        // Maximum 100 items are stored.
        // get data from data storage
        let historyArray : NSArray? = userDefault.array(forKey: rateKey) as NSArray?
        
        if historyArray == nil {
            return nil
        }
        
        for var item in historyArray! as! [[String:Any]] {
            //print(item["exchangedate"])
            //print(item["sellCash"])
            let rateItem = Rate()
            rateItem.rate = Double(item["sellCash"] as! String)!
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = "yyyyMMdd"
            let getDate : Date = dateFormatter.date(from: item["exchangedate"] as! String)!
            rateItem.time = getDate
            //print(getDate)

            jpyList.append(rateItem)
            
            // update
            itemRequired = itemRequired - 1
            if itemRequired <= 0 {
                break
            }
        }
        
        return jpyList
    }
}
