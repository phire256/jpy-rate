//
//  OtherTableTableViewController.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2017/2/11.
//  Copyright © 2017年 Yong Min Chen. All rights reserved.
//

import UIKit

class OtherTableTableViewController: UITableViewController, TokenTaskDelegate {
    
    let tokenTask = TokenTask()
    var notificationStatus: NotificationStatus = .NoToken
    
    let optionStringList : [String] =
        [
            NSLocalizedString("Notification", comment: ""),
            NSLocalizedString("History", comment: ""),
        ]
    
    let aboutStringList : [String] =
        [
            "LICENSE"
        ]
    
    enum sectionList : Int {
        case Option = 0
        case About = 1
        
        static var count: Int { return sectionList.About.rawValue + 1 }
    }
    
    enum optionList : Int {
        case Notification = 0
        case History = 1
        
        static var count: Int { return optionList.History.rawValue + 1 }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.delegate = self
        
        tokenTask.delegate = self
        tokenTask.update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func refreshView() {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectionList.Option.rawValue {
            let count = optionCount()
            return count
        } else if section == sectionList.About.rawValue {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // cell selection
        var cellIdentifier = "Cell"
        if indexPath.section == sectionList.Option.rawValue {
            let index = optionIndex(indexPath.row)
            if index == optionList.Notification.rawValue {
                cellIdentifier = "OnOffCell"
            }
        }
        
        // init cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if cellIdentifier == "OnOffCell" {
            let onOffSwitch = UISwitch()
            onOffSwitch.addTarget(self, action: #selector(onSwitchChanged), for: .touchUpInside)
            if self.notificationStatus == .On {
                onOffSwitch.isOn = true
            } else {
                onOffSwitch.isOn = false
            }
            cell.accessoryView = onOffSwitch
        }

        // Configure the cell...
        if indexPath.section == sectionList.Option.rawValue {
            let index = optionIndex(indexPath.row)
            cell.textLabel?.text = optionStringList[index]
        } else if indexPath.section == sectionList.About.rawValue {
            cell.textLabel?.text = aboutStringList[0]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == sectionList.Option.rawValue {
            let index = optionIndex(indexPath.row)
            if index == optionList.History.rawValue {
                performSegue(withIdentifier: "HistorySegue", sender: nil)
            } else {
                // toggle notification
                
            }
        } else if indexPath.section == sectionList.About.rawValue {
            performSegue(withIdentifier: "LicenseSegue", sender: nil)
        }
    }
    
    // 
    fileprivate func optionIndex(_ row: Int) -> Int {
        var optionIndex = row
        if self.notificationStatus == .NoToken {
            optionIndex = optionIndex + 1
        }
        return optionIndex
    }
    
    fileprivate func optionCount() -> Int {
        if self.notificationStatus == .NoToken {
            return optionList.count - 1
        }
        return optionList.count
    }
    
    func onSwitchChanged(_ sender: UISwitch) {
        //print(sender.isOn)
        if sender.isOn {
            tokenTask.enableNotification()
        } else {
            tokenTask.disableNotifcation()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destination.isKind(of: HistoryViewController.self) {
            let dstVc = segue.destination as! HistoryViewController
            // do nothing
        }
    }

    // MARK: - TokenTaskDelegate
    func onTokenTaskComplete(status: NotificationStatus) {
        self.notificationStatus = status
        
        refreshView()
    }
}
