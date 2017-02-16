//
//  TokenTask.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2017/2/16.
//  Copyright © 2017年 Yong Min Chen. All rights reserved.
//

import Foundation

enum NotificationStatus {
    case NoToken
    case Off
    case On
}

protocol TokenTaskDelegate {
    func onTokenTaskComplete(status: NotificationStatus)
}

class TokenTask
{
    var delegate: TokenTaskDelegate? = nil
    
    func update() {
        updateNotificationData()
    }
    
    func enableNotification() {
        self.enableNotify(true)
    }
    
    func disableNotifcation() {
        self.enableNotify(false)
    }
    
    fileprivate func sendNotificationStatus(status: NotificationStatus) {
        DispatchQueue.main.async {
            self.delegate?.onTokenTaskComplete(status: status)
        }
    }
    
    fileprivate func loadNotifyByToken() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let deviceToken = appDelegate.deviceToken
        
        if deviceToken != nil {
            loadNotify(token: deviceToken!)
        } else {
            if delegate != nil {
                self.sendNotificationStatus(status: .NoToken)
            }
        }
        
        return (deviceToken != nil)
    }
    
    fileprivate func updateNotificationData() {
        let tokenRefreshed = loadNotifyByToken()
        
        if !tokenRefreshed {
            // append callback
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.receiveTokenHandler = self.didReceiveToken
        }
    }
    
    fileprivate func didReceiveToken(_ hasToken: Bool) {
        if hasToken {
            let tokenRefreshed = loadNotifyByToken()
            
            if tokenRefreshed {
                // remove callback
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.receiveTokenHandler = nil
            }
        }
    }
    
    // MARK: - token post request
    fileprivate func sendTokenRequest(token:String, chooseAction:Int) {
        var responseString: String?
        var request = URLRequest(url: URL(string: "\(ApiSite.site)token")!)
        request.httpMethod = "POST"
        let postString = "token=\(token)&info=\(chooseAction)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask (with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)
            //print("responseString= \(responseString)")
            
            // refresh notify view for action 0 : query
            if chooseAction == 0 {
                var notificationEnable: Bool = false
                if responseString == "1" {
                    notificationEnable = true
                } else {
                    notificationEnable = false
                }
                
                //print("Notification:\(notificationEnable)")
                if notificationEnable {
                    self.sendNotificationStatus(status: .On)
                } else {
                    self.sendNotificationStatus(status: .Off)
                }
            } else if chooseAction == 1 || chooseAction == 2 {
                // update data to refresh view
                self.loadNotify(token: token)
            }
        }
        task.resume()
    }

    fileprivate func loadNotify(token: String) {
        sendTokenRequest(token: token, chooseAction: 0)
    }
    
    fileprivate func setNotify(token: String) {
        sendTokenRequest(token: token, chooseAction: 1)
    }
    
    fileprivate func removeNotify(token: String) {
        sendTokenRequest(token: token, chooseAction: 2)
    }
    
    fileprivate func enableNotify(_ enable: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let deviceToken = appDelegate.deviceToken
        if deviceToken != nil {
            if enable {
                // enable
                setNotify(token: deviceToken!)
                //notificationEnable = true
            } else {
                // disable
                removeNotify(token: deviceToken!)
                //notificationEnable = false
            }
        }
    }
}
