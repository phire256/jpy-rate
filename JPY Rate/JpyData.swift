//
//  JpyData.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2016/2/12.
//  Copyright (c) 2016年 Yong Min Chen. All rights reserved.
//

import Foundation

class JpyData: NSObject, NSURLConnectionDataDelegate{
    
    // MARK:- store keys
    fileprivate let frontKey = "front"
    fileprivate let rearKey = "rear"
    fileprivate let queueSizeKey = "maxqueue"
    fileprivate let timeKey = "time"
    fileprivate let rateKey = "rate"
    fileprivate let showSizeKey = "showsize"
    
    fileprivate let userDefault = UserDefaults.standard
    fileprivate var data: NSMutableData? = nil
    
    fileprivate var connectionHandler: ((Bool) -> Void)? = nil
    
    // MARK:- private functions
    // TODO: make resetDatabase() private!
    func resetDatabase() {
        userDefault.set(0, forKey: frontKey)
        userDefault.set(0, forKey: rearKey)
        userDefault.set(101, forKey: queueSizeKey)
        userDefault.set(5, forKey: showSizeKey)
    }
    
    // NOTE: front & rear should be initialized with queueSize.
    fileprivate func tryGetQueueSize() -> NSInteger {
        let queueSize = userDefault.integer(forKey: queueSizeKey)
        if (queueSize == 0) {
            resetDatabase()
            return userDefault.integer(forKey: queueSizeKey)
        }
        return queueSize
    }
    
    fileprivate func tryGetShowSize() -> NSInteger {
        let showSize = userDefault.integer(forKey: showSizeKey)
        if showSize == 0 {
            userDefault.set(5, forKey: showSizeKey)
            return userDefault.integer(forKey: showSizeKey)
        }
        return showSize
    }
    fileprivate func tryGetDataSize() -> NSInteger {
        // try init front & rear
        let queueSize = tryGetQueueSize()
        let front = userDefault.integer(forKey: frontKey)
        let rear = userDefault.integer(forKey: rearKey)
        
        if front == rear {
            return 0
        } else if front > rear {
            return rear + queueSize - front
        } else {
            return rear - front
        }
    }
    fileprivate func isDataAlreadyExists(_ time: Int) -> Bool {
        let queueSize = tryGetQueueSize()
        let front = userDefault.integer(forKey: frontKey)
        var rear = userDefault.integer(forKey: rearKey)
        // check empty
        if front != rear {
            if rear < front {
                rear = rear + queueSize
            }
            for currentId in front ..< rear {
                let timeInteger = userDefault.integer(forKey: "\(timeKey)\(currentId)") as NSInteger
                if time == timeInteger {
                    return true
                }
            }
        }
        return false
    }
    fileprivate func addRate(_ rate: Double, updateTime: Int) {
        let queueSize = tryGetQueueSize()
        let front = userDefault.integer(forKey: frontKey)
        let rear = userDefault.integer(forKey: rearKey)
        // check full
        if front == (rear + 1) % queueSize {
            // delete the oldest item
            userDefault.set((front + 1) % queueSize, forKey: frontKey)
        }
        // add item
        userDefault.set(rate, forKey: "\(rateKey)\(rear)")
        
        userDefault.set(updateTime, forKey: "\(timeKey)\(rear)")
        
        // update rear
        userDefault.set((rear + 1) % queueSize, forKey: rearKey)
    }
    
    // MARK:- connection data delegate
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.data = (data as NSData).mutableCopy() as? NSMutableData
        
        // debug b
        let tmpString = "{\"createTime\":1474945898, \"updateTime\":false, \"rates\":null}"
        let tmpData = tmpString.data(using: .utf8)
        self.data = NSMutableData(data: tmpData!)
        // debug e
    }
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        var hasItem = false
        let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: self.data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        
        // check error, there might be error when data api fails
        if (jsonResult["updateTime"] as! NSInteger == 0) {
            return
        }
        if (jsonResult["rates"] is NSNull) {
            return
        }
        
        // add item
        if !isDataAlreadyExists(jsonResult["updateTime"] as! NSInteger) {
            addRate((jsonResult["rates"] as! NSString).doubleValue,
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
    
    // MARK:- public functions
    func updateData(_ handler: ((Bool) -> Void)?) {
        // handler
        self.connectionHandler = handler
        // connection
        let urlPath = ApiSite.site
        let url = URL(string: urlPath)
        let request = URLRequest(url: url!)
        let connection = NSURLConnection(request: request, delegate: self)
        connection!.start()
    }
    func getShowSize() -> NSInteger {
        return tryGetShowSize()
    }
    func getDataSize() -> NSInteger {
        return min(tryGetShowSize(), tryGetDataSize())
    }
    func getRateByIndex(_ index: NSInteger, isReverseOrder: Bool) -> Rate? {
        if (index < 0) {
            return nil
        }
        
        // Maximum 100 items are stored.
        // get data from data storage
        
        let queueSize = tryGetQueueSize()
        let dataSize = tryGetDataSize()
        // index should be fall inside queue
        if (index >= dataSize) {
            return nil
        }
        let front = userDefault.integer(forKey: frontKey)
        let rear = userDefault.integer(forKey: rearKey)
        
        // check empty
        if (front == rear) {
            return nil
        } else {
            var currentId = -1;
            if isReverseOrder {
                currentId = (rear - 1 - index + queueSize) % queueSize
            } else {
                currentId = (front + index) % queueSize
            }

            let timeInteger = userDefault.integer(forKey: "\(timeKey)\(currentId)") as NSInteger
            let rateDouble = userDefault.double(forKey: "\(rateKey)\(currentId)")
            let rate = Rate(rate: rateDouble, time: Date(timeIntervalSince1970: TimeInterval(timeInteger)))
            
            return rate
        }
    }
    func getArray(_ numberOfItems:NSInteger) -> [Rate]? {
        if numberOfItems < 0 {
            return nil
        }
        
        var jpyList = [Rate]()
        // Maximum 100 items are stored.
        // get data from data storage
        
        let queueSize = tryGetQueueSize()
        
        let front = userDefault.integer(forKey: frontKey)
        var rear = userDefault.integer(forKey: rearKey)
        
        // check empty
        if front != rear {
            if rear < front {
                rear = rear + min(queueSize, numberOfItems)
            }
            for i in front ..< rear {
                let currentId = i % queueSize
                let timeInteger = userDefault.integer(forKey: "\(timeKey)\(currentId)") as NSInteger
                let rateDouble = userDefault.double(forKey: "\(rateKey)\(currentId)")
                let rate = Rate(rate: rateDouble, time: Date(timeIntervalSince1970: TimeInterval(timeInteger)))
                jpyList.append(rate)
            }
        }
        
        return jpyList
    }
}
