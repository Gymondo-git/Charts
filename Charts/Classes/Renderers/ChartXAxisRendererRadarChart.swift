//
//  ChartXAxisRendererRadarChart.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
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


open class ChartXAxisRendererRadarChart: ChartXAxisRenderer
{
    open weak var chart: RadarChartView?
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, chart: RadarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: nil)
        
        self.chart = chart
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        guard let
            xAxis = xAxis,
            let chart = chart
            else { return }
        
        if (!xAxis.isEnabled || !xAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let labelFont = xAxis.labelFont
        let labelTextColor = xAxis.labelTextColor
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        let drawLabelAnchor = CGPoint(x: 0.5, y: 0.0)
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        let modulus = xAxis.axisLabelModulus
        for i in stride(from: 0, to: xAxis.values.count, by: modulus)
        {
            let label = xAxis.values[i]
            
            if (label == nil)
            {
                continue
            }
            
            let angle = (sliceangle * CGFloat(i) + chart.rotationAngle).truncatingRemainder(dividingBy: 360.0)
            
            let p = ChartUtils.getPosition(center: center, dist: CGFloat(chart.yRange) * factor + xAxis.labelRotatedWidth / 2.0, angle: angle)
            
            drawLabel(context: context, label: label!, xIndex: i, x: p.x, y: p.y - xAxis.labelRotatedHeight / 2.0, attributes: [NSAttributedString.Key.font: labelFont, NSAttributedString.Key.foregroundColor: labelTextColor], anchor: drawLabelAnchor, angleRadians: labelRotationAngleRadians)
        }
    }
    
    open func drawLabel(context: CGContext, label: String, xIndex: Int, x: CGFloat, y: CGFloat, attributes: [NSAttributedString.Key: Any], anchor: CGPoint, angleRadians: CGFloat)
    {
        guard let xAxis = xAxis else { return }
        
        let formattedLabel = xAxis.valueFormatter?.stringForXValue(xIndex, original: label, viewPortHandler: viewPortHandler) ?? label
        ChartUtils.drawText(context: context, text: formattedLabel, point: CGPoint(x: x, y: y), attributes: attributes, anchor: anchor, angleRadians: angleRadians)
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        /// XAxis LimitLines on RadarChart not yet supported.
    }
}
