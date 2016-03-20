//
//  TableViewController.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2015/1/1.
//  Copyright (c) 2015年 Yong Min Chen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var pickerView: UIPickerView!
    private let jpyData = JpyData()
    
    override func viewWillAppear(animated: Bool) {
        // debug: reset database
        //jpyData.resetDatabase()
    }
    
    override func viewDidLoad() {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        updateData(self.refreshViewWhenNewItemComes)
    }
    
    private func refreshViewWhenNewItemComes(hasItem: Bool) {
        if hasItem {
            self.refreshView()
        }
    }
    
    
    private func updateData(handler: ((Bool) -> Void)?) {
        jpyData.updateData(handler)
    }
    
    private func refreshView() {
        self.pickerView.reloadAllComponents()
    }
    
    // MARK:- Refresh button callback
    @IBAction func onRefreshButtonClicked(sender: UIButton) {
        updateData(self.refreshViewWhenNewItemComes)
    }
    
    // MARK: - Table View callbacks
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2016-03-06   phire : hide table view.
        return 0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("configCell", forIndexPath: indexPath) 
        
        cell.textLabel!.text = "Item number to show"
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        cell.detailTextLabel!.text = "\(jpyData.getShowSize())"
        
        return cell
    }
    
    // MARK: - Picker View callbacks
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return jpyData.getDataSize()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // TODO: set title
        let rateForRow = jpyData.getRateByIndex(row, isReverseOrder: true)
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.doesRelativeDateFormatting = true
        let timeString = formatter.stringFromDate(rateForRow!.time)
        if (rateForRow != nil) {
            return "\(timeString) \(rateForRow!.rate)"
        }
        
        return ""
    }
    
    
}
