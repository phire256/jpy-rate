//
//  Rate.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2016/2/13.
//  Copyright (c) 2016年 Yong Min Chen. All rights reserved.
//

import Foundation

class Rate {
    var rate : Double = 0
    var time : Date = Date()
    
    init() {
    }
    
    init(rate: Double, time: Date) {
        self.rate = rate
        self.time = time
    }
}
