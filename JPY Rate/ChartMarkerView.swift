//
//  ChartMarkerView.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2017/2/12.
//  Copyright © 2017年 Yong Min Chen. All rights reserved.
//

import UIKit

class ChartMarkerView: UIView, IMarker {

    @IBOutlet weak var textLabel: UILabel!
    weak var chartView: ChartViewBase? = nil
    var aboveBar : Bool = true
    
    
    // init func
    static func instantiateFromNib() -> ChartMarkerView {
        return Bundle.main.loadNibNamed("ChartMarkerView", owner: self, options: nil)![0] as! ChartMarkerView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        let containerView = UINib.init(nibName: "ChartMarkerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
//        let newFrame = CGRect(x: 0, y:0, width: self.frame.size.width, height: self.frame.size.height)
//        containerView.frame = newFrame
//        self.addSubview(containerView)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
    }
    
    fileprivate func loadXib() {
        
    }
    
    // MARK:- IMarker protocol
    
    /// - returns: The desired (general) offset you wish the IMarker to have on the x-axis.
    ///
    /// By returning x: -(width / 2) you will center the IMarker horizontally.
    ///
    /// By returning y: -(height / 2) you will center the IMarker vertically.
    var offset: CGPoint {
        get {
            return CGPoint(x: -(frame.width / 2), y: -(frame.height / 2))
            //return CGPoint(x: 0, y: 0)
        }
    }
    /// - returns: The offset for drawing at the specific `point`.
    ///            This allows conditional adjusting of the Marker position.
    ///            If you have no adjustments to make, return self.offset().
    ///
    /// - parameter point: This is the point at which the marker wants to be drawn. You can adjust the offset conditionally based on this argument.
    func offsetForDrawing(atPoint: CGPoint) -> CGPoint {
        if chartView == nil {
            return CGPoint(x: atPoint.x,
                           y: atPoint.y)
        } else {
            return CGPoint(x: (chartView?.frame.minX)! + atPoint.x,
                           y: (chartView?.frame.minY)! + atPoint.y)
        }
    }
    
    func offsetForDrawingAboveChart(atPoint: CGPoint) -> CGPoint {
        if chartView == nil {
            return offsetForDrawing(atPoint: atPoint)
        } else {
            return CGPoint(x: (chartView?.frame.midX)!,
                           y: (chartView?.frame.minY)!)
        }
    }
    
    /// This method enables a custom IMarker to update it's content every time the IMarker is redrawn according to the data entry it points to.
    ///
    /// - parameter entry: The Entry the IMarker belongs to. This can also be any subclass of Entry, like BarEntry or CandleEntry, simply cast it at runtime.
    /// - parameter highlight: The highlight object contains information about the highlighted value such as it's dataset-index, the selected range or stack-index (only stacked bar entries).
    func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
    /// Draws the IMarker on the given position on the given context
    func draw(context: CGContext, point: CGPoint){
        if aboveBar {
            self.center = self.offsetForDrawing(atPoint: point)
        } else {
            self.center = self.offsetForDrawingAboveChart(atPoint: point)
        }
        
        //print(self.center)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
