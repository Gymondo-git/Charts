//
//  CandleChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


open class CandleChartDataSet: LineScatterCandleRadarChartDataSet, ICandleChartDataSet
{
    
    public required init()
    {
        super.init()
    }
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    open override func calcMinMax(start: Int, end: Int)
    {
        let yValCount = self.entryCount
        
        if yValCount == 0
        {
            return
        }
        
        let entries = yVals as! [CandleChartDataEntry]
        var endValue : Int
        
        if end == 0 || end >= yValCount
        {
            endValue = yValCount - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = .greatestFiniteMagnitude
        _yMax = -.greatestFiniteMagnitude
        
        for i in stride(from: start, through: endValue, by: 1)
        {
            let e = entries[i]
            
            if (e.low < _yMin)
            {
                _yMin = e.low
            }
            
            if (e.high > _yMax)
            {
                _yMax = e.high
            }
        }
    }
    
    // MARK: - Styling functions and accessors
    
    /// the space between the candle entries
    ///
    /// **default**: 0.1 (10%)
    fileprivate var _barSpace = CGFloat(0.1)
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    open var barSpace: CGFloat
    {
        set
        {
            if (newValue < 0.0)
            {
                _barSpace = 0.0
            }
            else if (newValue > 0.45)
            {
                _barSpace = 0.45
            }
            else
            {
                _barSpace = newValue
            }
        }
        get
        {
            return _barSpace
        }
    }
    
    /// should the candle bars show?
    /// when false, only "ticks" will show
    ///
    /// **default**: true
    open var showCandleBar: Bool = true
    
    /// the width of the candle-shadow-line in pixels.
    ///
    /// **default**: 1.5
    open var shadowWidth = CGFloat(1.5)
    
    /// the color of the shadow line
    open var shadowColor: NSUIColor?
    
    /// use candle color for the shadow
    open var shadowColorSameAsCandle = false
    
    /// Is the shadow color same as the candle color?
    open var isShadowColorSameAsCandle: Bool { return shadowColorSameAsCandle }
    
    /// color for open == close
    open var neutralColor: NSUIColor?
    
    /// color for open > close
    open var increasingColor: NSUIColor?
    
    /// color for open < close
    open var decreasingColor: NSUIColor?
    
    /// Are increasing values drawn as filled?
    /// increasing candlesticks are traditionally hollow
    open var increasingFilled = false
    
    /// Are increasing values drawn as filled?
    open var isIncreasingFilled: Bool { return increasingFilled }
    
    /// Are decreasing values drawn as filled?
    /// descreasing candlesticks are traditionally filled
    open var decreasingFilled = true
    
    /// Are decreasing values drawn as filled?
    open var isDecreasingFilled: Bool { return decreasingFilled }
}
