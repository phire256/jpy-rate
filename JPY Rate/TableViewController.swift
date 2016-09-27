//
//  TableViewController.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2015/1/1.
//  Copyright (c) 2015年 Yong Min Chen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    fileprivate let jpyData = JpyData()
    @IBOutlet weak var notificationText: UILabel!
    @IBOutlet weak var notificationTextOn: UILabel!
    @IBOutlet weak var notificationTextPending: UILabel!
    fileprivate var notificationEnable = false
    
    override func viewWillAppear(_ animated: Bool) {
        // debug: reset database
        //jpyData.resetDatabase()
    }
    
    override func viewDidLoad() {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        updateAllData()
        
        // delay update data again for token loading
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.updateAllData()
        }
    }
    
    fileprivate func refreshViewWhenNewItemComes(_ hasItem: Bool) {
        if hasItem {
            self.refreshView()
        }
    }
    
    fileprivate func updateAllData() {
        updateRateData(self.refreshViewWhenNewItemComes)
        
        updateNotificationData()
    }
    
    fileprivate func updateRateData(_ handler: ((Bool) -> Void)?) {
        jpyData.updateData(handler)
    }
    
    fileprivate func updateNotificationData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let deviceToken = appDelegate.deviceToken
        
        if deviceToken != nil {
            loadNotify(token: deviceToken!)
        }
    }
    
    fileprivate func refreshView() {
        self.pickerView.reloadAllComponents()
    }
    
    fileprivate func refreshNotifitionView() {
        if notificationEnable {
            notificationTextOn.isHidden = false
            notificationText.isHidden = true
            notificationTextPending.isHidden = true
        } else {
            notificationTextOn.isHidden = true
            notificationText.isHidden = false
            notificationTextPending.isHidden = true
        }
    }
    
    // MARK:- Refresh button callback
    @IBAction func onRefreshButtonClicked(_ sender: UIButton) {
        //updateRateData(self.refreshViewWhenNewItemComes)
        self.updateAllData()
    }
    @IBAction func onNotificationToggleClicked(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let deviceToken = appDelegate.deviceToken
        if deviceToken != nil {
            if notificationEnable {
                // disable
                removeNotify(token: deviceToken!)
                //notificationEnable = false
            } else {
                // enable
                setNotify(token: deviceToken!)
                //notificationEnable = true
            }
        }
    }
    
    // MARK: - Table View callbacks
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2016-03-06   phire : hide table view.
        return 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "configCell", for: indexPath) 
        
        cell.textLabel!.text = "Item number to show"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        cell.detailTextLabel!.text = "\(jpyData.getShowSize())"
        
        return cell
    }
    
    // MARK: - Picker View callbacks
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return jpyData.getDataSize()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // TODO: set title
        let rateForRow = jpyData.getRateByIndex(row, isReverseOrder: true)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.doesRelativeDateFormatting = true
        let timeString = formatter.string(from: rateForRow!.time)
        if (rateForRow != nil) {
            return "\(timeString) \(rateForRow!.rate)"
        }
        
        return ""
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
                if responseString == "1" {
                    self.notificationEnable = true
                } else {
                    self.notificationEnable = false
                }
                
                print("Notification:\(self.notificationEnable)")
                DispatchQueue.main.async {
                    self.refreshNotifitionView()
                }
            } else if chooseAction == 1 || chooseAction == 2 {
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
}
