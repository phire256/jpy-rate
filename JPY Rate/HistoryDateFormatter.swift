//
//  HistoryDateFormatter.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2017/2/14.
//  Copyright © 2017年 Yong Min Chen. All rights reserved.
//

import Foundation
import Charts

class HistoryDateFormatter : NSObject, IAxisValueFormatter
{
    var rateMapping : [Rate]? = nil
    var isReversed : Bool = false
    var start : Int = 0
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if rateMapping != nil {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy/MM/dd"
            //print(value)
            //print(rateMapping?[0].time)
            //print(formatter.string(from: (rateMapping?[0].time)!))
            if !isReversed {
                return formatter.string(from: rateMapping![Int(value - 1) - start].time)
            } else {
                return formatter.string(from: rateMapping![Int(Double((rateMapping?.count)!) - value + 1) - start].time)
            }
        }
        
        return ""
    }

}
