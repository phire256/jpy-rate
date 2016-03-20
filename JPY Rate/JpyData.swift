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
    private let frontKey = "front"
    private let rearKey = "rear"
    private let queueSizeKey = "maxqueue"
    private let timeKey = "time"
    private let rateKey = "rate"
    private let showSizeKey = "showsize"
    
    private let userDefault = NSUserDefaults.standardUserDefaults()
    private var data: NSMutableData? = nil
    
    private var connectionHandler: ((Bool) -> Void)? = nil
    
    // MARK:- private functions
    // TODO: make resetDatabase() private!
    func resetDatabase() {
        userDefault.setInteger(0, forKey: frontKey)
        userDefault.setInteger(0, forKey: rearKey)
        userDefault.setInteger(101, forKey: queueSizeKey)
        userDefault.setInteger(5, forKey: showSizeKey)
    }
    
    // NOTE: front & rear should be initialized with queueSize.
    private func tryGetQueueSize() -> NSInteger {
        let queueSize = userDefault.integerForKey(queueSizeKey)
        if (queueSize == 0) {
            resetDatabase()
            return userDefault.integerForKey(queueSizeKey)
        }
        return queueSize
    }
    
    private func tryGetShowSize() -> NSInteger {
        let showSize = userDefault.integerForKey(showSizeKey)
        if showSize == 0 {
            userDefault.setInteger(5, forKey: showSizeKey)
            return userDefault.integerForKey(showSizeKey)
        }
        return showSize
    }
    private func tryGetDataSize() -> NSInteger {
        // try init front & rear
        let queueSize = tryGetQueueSize()
        let front = userDefault.integerForKey(frontKey)
        let rear = userDefault.integerForKey(rearKey)
        
        if front == rear {
            return 0
        } else if front > rear {
            return rear + queueSize - front
        } else {
            return rear - front
        }
    }
    private func isDataAlreadyExists(time: Int) -> Bool {
        let queueSize = tryGetQueueSize()
        let front = userDefault.integerForKey(frontKey)
        var rear = userDefault.integerForKey(rearKey)
        // check empty
        if front != rear {
            if rear < front {
                rear = rear + queueSize
            }
            for var currentId = front; currentId < rear ; currentId++ {
                let timeInteger = userDefault.integerForKey("\(timeKey)\(currentId)") as NSInteger
                if time == timeInteger {
                    return true
                }
            }
        }
        return false
    }
    private func addRate(rate: Double, updateTime: Int) {
        let queueSize = tryGetQueueSize()
        let front = userDefault.integerForKey(frontKey)
        let rear = userDefault.integerForKey(rearKey)
        // check full
        if front == (rear + 1) % queueSize {
            // delete the oldest item
            userDefault.setInteger((front + 1) % queueSize, forKey: frontKey)
        }
        // add item
        userDefault.setDouble(rate, forKey: "\(rateKey)\(rear)")
        
        userDefault.setInteger(updateTime, forKey: "\(timeKey)\(rear)")
        
        // update rear
        userDefault.setInteger((rear + 1) % queueSize, forKey: rearKey)
    }
    
    // MARK:- connection data delegate
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.data = data.mutableCopy() as? NSMutableData
    }
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var hasItem = false
        let jsonResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(self.data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        
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
    func updateData(handler: ((Bool) -> Void)?) {
        // handler
        self.connectionHandler = handler
        // connection
        let urlPath = "http://jpyapi-1172.appspot.com/"
        let url = NSURL(string: urlPath)
        let request = NSURLRequest(URL: url!)
        let connection = NSURLConnection(request: request, delegate: self)
        connection!.start()
    }
    func getShowSize() -> NSInteger {
        return tryGetShowSize()
    }
    func getDataSize() -> NSInteger {
        return min(tryGetShowSize(), tryGetDataSize())
    }
    func getRateByIndex(index: NSInteger, isReverseOrder: Bool) -> Rate? {
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
        let front = userDefault.integerForKey(frontKey)
        let rear = userDefault.integerForKey(rearKey)
        
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

            let timeInteger = userDefault.integerForKey("\(timeKey)\(currentId)") as NSInteger
            let rateDouble = userDefault.doubleForKey("\(rateKey)\(currentId)")
            let rate = Rate(rate: rateDouble, time: NSDate(timeIntervalSince1970: NSTimeInterval(timeInteger)))
            
            return rate
        }
    }
    func getArray(numberOfItems:NSInteger) -> [Rate]? {
        if numberOfItems < 0 {
            return nil
        }
        
        var jpyList = [Rate]()
        // Maximum 100 items are stored.
        // get data from data storage
        
        let queueSize = tryGetQueueSize()
        
        let front = userDefault.integerForKey(frontKey)
        var rear = userDefault.integerForKey(rearKey)
        
        // check empty
        if front != rear {
            if rear < front {
                rear = rear + min(queueSize, numberOfItems)
            }
            for var i = front; i < rear; i++ {
                let currentId = i % queueSize
                let timeInteger = userDefault.integerForKey("\(timeKey)\(currentId)") as NSInteger
                let rateDouble = userDefault.doubleForKey("\(rateKey)\(currentId)")
                let rate = Rate(rate: rateDouble, time: NSDate(timeIntervalSince1970: NSTimeInterval(timeInteger)))
                jpyList.append(rate)
            }
        }
        
        return jpyList
    }
}
