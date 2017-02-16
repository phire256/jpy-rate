//
//  HistoryViewController.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2017/2/11.
//  Copyright © 2017年 Yong Min Chen. All rights reserved.
//

import UIKit
import Charts

class HistoryViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var rangeSlider: UISlider!
    
    fileprivate let historyData = HistoryData()
    fileprivate let historyFormatter = HistoryDateFormatter()
    private var range = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        rangeSlider.minimumValue = 5
        rangeSlider.maximumValue = 60
        rangeSlider.value = Float(range)
        
        markerView.chartView = chartView
        markerView.isHidden = true
        self.view.addSubview(markerView)
        chartView.marker = markerView
        
        
        chartView.delegate = self
        
        
        self.initChart()
        self.updateChart()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        historyData.updateData(self.refreshViewWhenNewItemComes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func refreshViewWhenNewItemComes(_ hasItem: Bool) {
        if hasItem {
            self.refreshView()
        }
    }
    
    fileprivate func refreshView() {
        self.updateChart()
    }
    
    // MARK:- chart
    private func initChart() {
        chartView.setScaleEnabled(false)
        chartView.legend.enabled = false
        chartView.chartDescription?.enabled = false
        chartView.doubleTapToZoomEnabled = false
        
    }
    private func updateChart() {
        
        let numberofItems = rangeSlider.value
        
        var circleRadius : CGFloat = 3.0
        if numberofItems > 40 {
            circleRadius = 0.0
        }
        
        
        let history = historyData.getArray(NSInteger(numberofItems))
        
        if history == nil || history?.count == 0 {
            return
        }
        //print(history?.count ?? 0)
        
        historyFormatter.rateMapping = history
        historyFormatter.isReversed = true
        
        let start = 1
        let yVals = NSMutableArray()
        var i = history!.count - 1 + start
        historyFormatter.start = start
        for var item in history! {
            //yVals.add(LineChartDataEntry(x: Double(i), y: item.rate))
            yVals.insert(BarChartDataEntry(x: Double(i), y: item.rate), at: 0)
            // update
            i = i - 1
        }
        
        if (chartView.data != nil && (chartView.data?.dataSetCount)! > 0)
        {
            let set1 = chartView.data?.dataSets[0] as! LineChartDataSet;
            set1.values = yVals as! [ChartDataEntry];
            
            set1.circleRadius = circleRadius
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            let set1 = LineChartDataSet(values: yVals as? [ChartDataEntry], label: "The year 2017")
            let blue = 0.6 as CGFloat
            let blue0 = UIColor(red: blue, green: blue + 0.2, blue: 1, alpha: 1)
            let blue1 = UIColor(red: 0, green: blue + 0.1, blue: 1, alpha: 1)
            let blue2 = UIColor(red: 0, green: blue + 0.05, blue: 1, alpha: 1)
            let blue3 = UIColor(red: 0, green: blue, blue: 1, alpha: 1)
            
            set1.setColors([blue1, blue2, blue3], alpha: 1.0)
            
            set1.setColor(.black)
            set1.setCircleColor(.black)
            set1.lineWidth = 1.0
            set1.circleRadius = circleRadius
            set1.drawCircleHoleEnabled = false;
            set1.valueFont = UIFont.systemFont(ofSize: 12)
            set1.formLineWidth = 1.0
            set1.formSize = 15.0
            
            let gradientColors = [blue0.cgColor, blue3.cgColor]
            
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)
            set1.fillAlpha = 1;
            //set1.fill = Fill(linearGradient: gradient!, angle: 90)
            set1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90)
            set1.drawFilledEnabled = true;

            
            let dataSets = NSMutableArray()
            dataSets.add(set1)
            
            let data = LineChartData(dataSets: dataSets as? [IChartDataSet])
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10.0))
            data.setDrawValues(false)
            
            chartView.data = data;
        }
        
        let xAxis = chartView.xAxis;
        xAxis.labelPosition = .bottom;
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        xAxis.drawGridLinesEnabled = false;
        xAxis.granularity = 1.0; // only intervals of 1 day
        xAxis.labelCount = 3;
        xAxis.valueFormatter = historyFormatter
        
        let yAxisMinimum = findMin(history!) - 0.01
        let yAxisMaximum = findMax(history!) + 0.01
        //print(yAxisMaximum)
        //print(yAxisMinimum)
        let yAxisLeft = chartView.getAxis(.left)
        yAxisLeft.axisMinimum = yAxisMinimum
        yAxisLeft.axisMaximum = yAxisMaximum
        let yAxisRight = chartView.getAxis(.right)
        yAxisRight.axisMinimum = yAxisMinimum
        yAxisRight.axisMaximum = yAxisMaximum
        
        
        
        // set x,y range
        chartView.setVisibleXRangeMaximum(Double(Int(numberofItems)))
        chartView.setVisibleYRangeMaximum(0.2, axis: .left)
        
        // move x to latest
        // move y center to 25
        //chartView.moveViewTo(xValue: 999, yValue: 0.25, axis: .left)
        //chartView.moveViewTo(xValue: 999, yValue: 0.25, axis: .left)
        // disable drag 
        chartView.dragEnabled = false
        
        chartView.drawMarkers = true
        
    }
    
    // MARK:- chartViewDelegate
    let markerView = ChartMarkerView.instantiateFromNib()
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        markerView.textLabel.text = (chartView.xAxis.valueFormatter?.stringForValue(entry.x, axis: nil))! + ": " + String(entry.y)
        markerView.aboveBar = false
        markerView.isHidden = false
    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
        markerView.isHidden = true
    }

    @IBAction func rangeSlidereChanged(_ sender: UISlider) {
        self.updateChart()
    }
    
    fileprivate func findMin(_ array: [Rate]) -> Double {
        if array.count == 0 {
            return -1
        }
        var min = array[0].rate
        
        for var item in array {
            if min > item.rate {
                min = item.rate
            }
        }
        
        return min
    }
    
    fileprivate func findMax(_ array: [Rate]) -> Double {
        if array.count == 0 {
            return -1
        }
        var max = array[0].rate
        
        for var item in array {
            if max < item.rate {
                max = item.rate
            }
        }
        
        return max
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
