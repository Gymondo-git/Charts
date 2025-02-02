//
//  ChartYAxis.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


/// Class representing the y-axis labels settings and its entries.
/// Be aware that not all features the YLabels class provides are suitable for the RadarChart.
/// Customizations that affect the value range of the axis need to be applied before setting data for the chart.
open class ChartYAxis: ChartAxisBase
{
    @objc(YAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case outsideChart
        case insideChart
    }
    
    ///  Enum that specifies the axis a DataSet should be plotted against, either Left or Right.
    @objc
    public enum AxisDependency: Int
    {
        case left
        case right
    }
    
    open var entries = [Double]()
    open var entryCount: Int { return entries.count; }
    
    /// the number of y-label entries the y-labels should have, default 6
    fileprivate var _labelCount = Int(6)
    
    /// indicates if the top y-label entry is drawn or not
    open var drawTopYLabelEntryEnabled = true
    
    /// if true, the y-labels show only the minimum and maximum value
    open var showOnlyMinMaxEnabled = false
    
    /// flag that indicates if the axis is inverted or not
    open var inverted = false
    
    /// This property is deprecated - Use `axisMinValue` instead.
  @available(*, deprecated, message: "Use axisMinValue instead.")
    open var startAtZeroEnabled: Bool
    {
        get
        {
            return isAxisMinCustom && _axisMinimum == 0.0
        }
        set
        {
            if newValue
            {
                axisMinValue = 0.0
            }
            else
            {
                resetCustomAxisMin()
            }
        }
    }
    
    /// if true, the set number of y-labels will be forced
    open var forceLabelsEnabled = false

    /// flag that indicates if the zero-line should be drawn regardless of other grid lines
    open var drawZeroLineEnabled = false
    
    /// Color of the zero line
    open var zeroLineColor: NSUIColor? = NSUIColor.gray
    
    /// Width of the zero line
    open var zeroLineWidth: CGFloat = 1.0
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    open var zeroLineDashPhase = CGFloat(0.0)
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    open var zeroLineDashLengths: [CGFloat]?
    
    /// the formatter used to customly format the y-labels
    open var valueFormatter: NumberFormatter?
    
    /// the formatter used to customly format the y-labels
    internal var _defaultValueFormatter = NumberFormatter()

    /// axis space from the largest value to the top in percent of the total axis range
    open var spaceTop = CGFloat(0.1)

    /// axis space from the smallest value to the bottom in percent of the total axis range
    open var spaceBottom = CGFloat(0.1)
    
    /// the position of the y-labels relative to the chart
    open var labelPosition = LabelPosition.outsideChart
    
    /// the side this axis object represents
    fileprivate var _axisDependency = AxisDependency.left
    
    /// the minimum width that the axis should take
    /// 
    /// **default**: 0.0
    open var minWidth = CGFloat(0)
    
    /// the maximum width that the axis can take.
    /// use Infinity for disabling the maximum.
    /// 
    /// **default**: CGFloat.infinity
    open var maxWidth = CGFloat(CGFloat.infinity)
    
    /// When true, axis labels are controlled by the `granularity` property.
    /// When false, axis values could possibly be repeated.
    /// This could happen if two adjacent axis values are rounded to same value.
    /// If using granularity this could be avoided by having fewer axis values visible.
    open var granularityEnabled = false
    
    fileprivate var _granularity = Double(1.0)
    
    /// The minimum interval between axis values.
    /// This can be used to avoid label duplicating when zooming in.
    ///
    /// **default**: 1.0
    open var granularity: Double
    {
        get
        {
            return _granularity
        }
        set
        {
            _granularity = newValue
            
            // set this to true if it was disabled, as it makes no sense to set this property with granularity disabled
            granularityEnabled = true
        }
    }
    
    public override init()
    {
        super.init()
        
        _defaultValueFormatter.minimumIntegerDigits = 1
        _defaultValueFormatter.maximumFractionDigits = 1
        _defaultValueFormatter.minimumFractionDigits = 1
        _defaultValueFormatter.usesGroupingSeparator = true
        self.yOffset = 0.0
    }
    
    public init(position: AxisDependency)
    {
        super.init()
        
        _axisDependency = position
        
        _defaultValueFormatter.minimumIntegerDigits = 1
        _defaultValueFormatter.maximumFractionDigits = 1
        _defaultValueFormatter.minimumFractionDigits = 1
        _defaultValueFormatter.usesGroupingSeparator = true
        self.yOffset = 0.0
    }
    
    open var axisDependency: AxisDependency
    {
        return _axisDependency
    }
    
    open func setLabelCount(_ count: Int, force: Bool)
    {
        _labelCount = count
        
        if (_labelCount > 25)
        {
            _labelCount = 25
        }
        if (_labelCount < 2)
        {
            _labelCount = 2
        }
    
        forceLabelsEnabled = force
    }
    
    /// the number of label entries the y-axis should have
    /// max = 25,
    /// min = 2,
    /// default = 6,
    /// be aware that this number is not fixed and can only be approximated
    open var labelCount: Int
    {
        get
        {
            return _labelCount
        }
        set
        {
            setLabelCount(newValue, force: false);
        }
    }
    
    open func requiredSize() -> CGSize
    {
        let label = getLongestLabel() as NSString
        var size = label.size(withAttributes: [NSAttributedString.Key.font: labelFont])
        size.width += xOffset * 2.0
        size.height += yOffset * 2.0
        size.width = max(minWidth, min(size.width, maxWidth > 0.0 ? maxWidth : size.width))
        return size
    }
    
    open func getRequiredHeightSpace() -> CGFloat
    {
        return requiredSize().height
    }

    open override func getLongestLabel() -> String
    {
        var longest = ""
        
        for i in 0 ..< entries.count
        {
            let text = getFormattedLabel(i)
            
            if (longest.count < text.count)
            {
                longest = text
            }
        }
        
        return longest
    }

    /// - returns: the formatted y-label at the specified index. This will either use the auto-formatter or the custom formatter (if one is set).
    open func getFormattedLabel(_ index: Int) -> String
    {
        if (index < 0 || index >= entries.count)
        {
            return ""
        }
        
      return (valueFormatter ?? _defaultValueFormatter).string(from: NSNumber(value: entries[index]))!
    }
    
    /// - returns: true if this axis needs horizontal offset, false if no offset is needed.
    open var needsOffset: Bool
    {
        if (isEnabled && isDrawLabelsEnabled && labelPosition == .outsideChart)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    open var isInverted: Bool { return inverted; }
    
    /// This is deprecated now, use `axisMinValue`
  @available(*, deprecated, message: "Use axisMinValue instead.")
    open var isStartAtZeroEnabled: Bool { return startAtZeroEnabled }

    /// - returns: true if focing the y-label count is enabled. Default: false
    open var isForceLabelsEnabled: Bool { return forceLabelsEnabled }

    open var isShowOnlyMinMaxEnabled: Bool { return showOnlyMinMaxEnabled; }
    
    open var isDrawTopYLabelEntryEnabled: Bool { return drawTopYLabelEntryEnabled; }
    
    /// Calculates the minimum, maximum and range values of the YAxis with the given minimum and maximum values from the chart data.
    /// - parameter dataMin: the y-min value according to chart data
    /// - parameter dataMax: the y-max value according to chart
    open func calculate(min dataMin: Double, max dataMax: Double)
    {
        // if custom, use value as is, else use data value
        var min = _customAxisMin ? _axisMinimum : dataMin
        var max = _customAxisMax ? _axisMaximum : dataMax

        // temporary range (before calculations)
        let range = abs(max - min)

        // in case all values are equal
        if range == 0.0
        {
            max = max + 1.0
            min = min - 1.0
        }

        // bottom-space only effects non-custom min
        if !_customAxisMin
        {
            let bottomSpace = range * Double(spaceBottom)
            _axisMinimum = min - bottomSpace
        }

        // top-space only effects non-custom max
        if !_customAxisMax
        {
            let topSpace = range * Double(spaceTop)
            _axisMaximum = max + topSpace
        }

        // calc actual range
        axisRange = abs(_axisMaximum - _axisMinimum)
    }

}
