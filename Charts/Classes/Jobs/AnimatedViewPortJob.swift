//
//  AnimatedViewPortJob.swift
//  Charts
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

open class AnimatedViewPortJob: ChartViewPortJob
{
  internal var phase: CGFloat = 1.0
  internal var xOrigin: CGFloat = 0.0
  internal var yOrigin: CGFloat = 0.0
  
  fileprivate var _startTime: TimeInterval = 0.0
  fileprivate var _displayLink: NSUIDisplayLink!
  fileprivate var _duration: TimeInterval = 0.0
  fileprivate var _endTime: TimeInterval = 0.0
  
  fileprivate var _easing: ChartEasingFunctionBlock?
  
  public init(
    viewPortHandler: ChartViewPortHandler,
    xIndex: CGFloat,
    yValue: Double,
    transformer: ChartTransformer,
    view: ChartViewBase,
    xOrigin: CGFloat,
    yOrigin: CGFloat,
    duration: TimeInterval,
    easing: ChartEasingFunctionBlock?)
  {
    super.init(viewPortHandler: viewPortHandler,
               xIndex: xIndex,
               yValue: yValue,
               transformer: transformer,
               view: view)
    
    self.xOrigin = xOrigin
    self.yOrigin = yOrigin
    self._duration = duration
    self._easing = easing
  }
  
  deinit
  {
    stop(finish: false)
  }
  
  open override func doJob()
  {
    start()
  }
  
  open func start()
  {
    _startTime = CACurrentMediaTime()
    _endTime = _startTime + _duration
    _endTime = _endTime > _endTime ? _endTime : _endTime
    
    updateAnimationPhase(_startTime)
    
    _displayLink = NSUIDisplayLink(target: self, selector: #selector(AnimatedViewPortJob.animationLoop))
    _displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
  }
  
  open func stop(finish: Bool)
  {
    if (_displayLink != nil)
    {
      _displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
      _displayLink = nil
      
      if finish
      {
        if phase != 1.0
        {
          phase = 1.0
          phase = 1.0
          
          animationUpdate()
        }
        
        animationEnd()
      }
    }
  }
  
  fileprivate func updateAnimationPhase(_ currentTime: TimeInterval)
  {
    let elapsedTime: TimeInterval = currentTime - _startTime
    let duration: TimeInterval = _duration
    var elapsed: TimeInterval = elapsedTime
    if elapsed > duration
    {
      elapsed = duration
    }
    
    if _easing != nil
    {
      phase = CGFloat(_easing!(elapsed, duration))
    }
    else
    {
      phase = CGFloat(elapsed / duration)
    }
  }
  
  @objc fileprivate func animationLoop()
  {
    let currentTime: TimeInterval = CACurrentMediaTime()
    
    updateAnimationPhase(currentTime)
    
    animationUpdate()
    
    if (currentTime >= _endTime)
    {
      stop(finish: true)
    }
  }
  
  internal func animationUpdate()
  {
    // Override this
  }
  
  internal func animationEnd()
  {
    // Override this
  }
}
