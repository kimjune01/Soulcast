//
//  SimpleOutgoingButton.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-04-01.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

class SimpleOutgoingButton: UIButton {
  var oval : CAShapeLayer!
  var crossOne : CAShapeLayer!
  var crossTwo : CAShapeLayer!
  var buttonSize: CGFloat = 250
  var shadowRadius: CGFloat = 10
  
  var buttonState: RecordButtonState = .Enabled {
    didSet {
      switch (oldValue, buttonState) {
      case (.Enabled, .Recording):
        depressButton()
        break
      case (.Recording, .Enabled):
        touchUpButton()
        break
      case (.Recording, .Disabled):
        //        requestFinishRecording()
        break
      case (.Disabled, .Enabled):
        
        break
      default:
        assert(false, "OOOPS!!!")
      }
    }
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    buttonSize = frame.width
    setupLayers()
  }
  
  required init(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setupLayers()
  }
  
  func setupLayers(){
    var buttonFrame = CAShapeLayer()
    buttonFrame.frame       = CGRectMake(0, 0, buttonSize, buttonSize)
    buttonFrame.fillColor   = UIColor(red:0.845, green: 0.845, blue:0.845, alpha:0.16).CGColor
    buttonFrame.strokeColor = UIColor(red:0.329, green: 0.329, blue:0.329, alpha:0.1).CGColor
    buttonFrame.lineWidth   = 3
    buttonFrame.path        = circlePath(buttonFrame.frame).CGPath
    self.layer.addSublayer(buttonFrame)
    
    var IndicatorCircle = CAShapeLayer()
    IndicatorCircle.frame       = CGRectMake(buttonSize*0.05, buttonSize*0.05, buttonSize*0.9, buttonSize*0.9)
    IndicatorCircle.fillColor   = nil
    IndicatorCircle.strokeColor = UIColor(red:0.778, green: 0.0656, blue:0.0791, alpha:0.3).CGColor
    IndicatorCircle.lineWidth   = 8
    IndicatorCircle.path        = circlePath(IndicatorCircle.frame).CGPath
    buttonFrame.addSublayer(IndicatorCircle)
    
    var InsideProgress = CAShapeLayer()
    InsideProgress.frame       = CGRectMake(buttonSize*0.05, buttonSize*0.05, buttonSize*0.9, buttonSize*0.9)
    InsideProgress.fillColor   = UIColor.clearColor().CGColor
    InsideProgress.strokeColor = UIColor(red:0.778, green: 0.0656, blue:0.0791, alpha:0.95).CGColor
    InsideProgress.lineWidth   = 7
    InsideProgress.strokeStart = 0.4
    InsideProgress.path        = circlePath(InsideProgress.frame).CGPath
    buttonFrame.addSublayer(InsideProgress)
    
    oval = CAShapeLayer()
    oval.frame     = CGRectMake(buttonSize*0.25, buttonSize*0.25, buttonSize*0.5, buttonSize*0.5)
    oval.fillColor = UIColor(red:0.78, green: 0.0667, blue:0.0784, alpha:1).CGColor
    oval.lineWidth = 0
    oval.path      = circlePath(oval.frame).CGPath
    
    oval.shadowPath = circlePath(oval.frame).CGPath
    oval.shadowRadius = shadowRadius
    oval.shadowOpacity = 0.7
    oval.shadowOffset = CGSize(width: buttonSize*0.02, height: buttonSize*0.02)
    oval.shadowColor = UIColor.blackColor().CGColor
    
    buttonFrame.addSublayer(oval)
    
    
    crossOne = CAShapeLayer()
    crossOne.frame     = CGRectMake(0, 0, buttonSize*0.6, 4)
    crossOne.position = buttonFrame.position
    crossOne.setValue(-45 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
    crossOne.fillColor = UIColor(red:0.78, green: 0.0667, blue:0.0784, alpha:1).CGColor
    crossOne.lineWidth = 0
    crossOne.path      = rectanglePath(crossOne.frame).CGPath
    buttonFrame.addSublayer(crossOne)
    
    crossTwo = CAShapeLayer()
    crossTwo.frame     = CGRectMake(0, 0, buttonSize*0.6, 4)
    crossTwo.position = buttonFrame.position
    crossTwo.setValue(-135 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
    crossTwo.fillColor = UIColor(red:0.78, green: 0.0667, blue:0.0784, alpha:1).CGColor
    crossTwo.lineWidth = 0
    crossTwo.path      = rectanglePath(crossTwo.frame).CGPath
    buttonFrame.addSublayer(crossTwo)
  }
  
  func depressButton() {
    oval.addAnimation(depressingAnimation(oval.shadowRadius, toRadius: 0, fromOpacity: oval.shadowOpacity, toOpacity: 0, fromScale: 1, toScale: 0.98), forKey: "depressingAnimation")
  }
  
  func touchUpButton() {
    oval.addAnimation(depressingAnimation(0, toRadius:oval.shadowRadius, fromOpacity:0, toOpacity:oval.shadowOpacity, fromScale: 0.98, toScale: 1), forKey: "depressingAnimation")
  }
  
  func showCircle() {
    
  }
  
  func hideCircle() {
    
  }
  
  @IBAction func startCircleAnimation(sender: AnyObject!){
    oval?.addAnimation(ovalAnimation(), forKey:"circleAnimation")
  }
  
  func showCross() {
    
  }
  
  func hideCross() {
    
  }
  
  func startCrossAnimation(sender: AnyObject!) {
    crossOne?.addAnimation(crossOneAnimation(), forKey:"crossOneAnimation")
    crossTwo?.addAnimation(crossTwoAnimation(), forKey:"crossTwoAnimation")
  }
  
  
  func ovalAnimation() -> CAKeyframeAnimation{
    var transformAnim            = CAKeyframeAnimation(keyPath:"transform")
    transformAnim.values         = [NSValue(CATransform3D: CATransform3DIdentity),
      NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
      NSValue(CATransform3D: CATransform3DMakeScale(1.13, 1.13, 1))]
    transformAnim.keyTimes       = [0, 0.594, 1]
    transformAnim.duration       = 0.253
    transformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
    transformAnim.autoreverses   = true
    transformAnim.fillMode = kCAFillModeBoth
    transformAnim.removedOnCompletion = false
    
    return transformAnim
  }
  
  func crossOneAnimation() -> CAAnimationGroup{
    var transformAnim            = CAKeyframeAnimation(keyPath:"transform")
    transformAnim.values         = [NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0.02, 1, 1), CATransform3DMakeRotation(-CGFloat(M_PI_4), 0, 0, 1))),
      NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(1.07, 1, 1), CATransform3DMakeRotation(-CGFloat(M_PI_4), 0, 0, 1))),
      NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_4), 0, 0, -1))]
    transformAnim.keyTimes       = [0, 0.86, 1]
    transformAnim.duration       = 0.15
    transformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
    
    var opacityAnim            = CABasicAnimation(keyPath:"opacity")
    opacityAnim.fromValue      = 0
    opacityAnim.toValue        = 1
    opacityAnim.duration       = 0.15
    opacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
    
    var roundedrectAnimGroup        = CAAnimationGroup()
    roundedrectAnimGroup.animations = [transformAnim, opacityAnim]
    roundedrectAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
    roundedrectAnimGroup.fillMode   = kCAFillModeForwards
    roundedrectAnimGroup.removedOnCompletion = false
    roundedrectAnimGroup.duration = QCMethod.maxDurationFromAnimations(roundedrectAnimGroup.animations as! [CAAnimation])
    
    
    return roundedrectAnimGroup
  }
  
  func crossTwoAnimation() -> CAAnimationGroup{
    var transformAnim            = CAKeyframeAnimation(keyPath:"transform")
    transformAnim.values         = [NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0.02, 1, 1), CATransform3DMakeRotation(-135 * CGFloat(M_PI/180), -0, 0, 1))),
      NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(1.07, 1, 1), CATransform3DMakeRotation(-135 * CGFloat(M_PI/180), -0, 0, 1))),
      NSValue(CATransform3D: CATransform3DMakeRotation(135 * CGFloat(M_PI/180), 0, 0, -1))]
    transformAnim.keyTimes       = [0, 0.86, 1]
    transformAnim.duration       = 0.15
    transformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
    
    var opacityAnim            = CABasicAnimation(keyPath:"opacity")
    opacityAnim.fromValue      = 0
    opacityAnim.toValue        = 1
    opacityAnim.duration       = 0.15
    opacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
    
    var roundedrectAnimGroup        = CAAnimationGroup()
    roundedrectAnimGroup.animations = [transformAnim, opacityAnim]
    roundedrectAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
    roundedrectAnimGroup.fillMode   = kCAFillModeForwards
    roundedrectAnimGroup.removedOnCompletion = false
    roundedrectAnimGroup.duration = QCMethod.maxDurationFromAnimations(roundedrectAnimGroup.animations as! [CAAnimation])
    
    
    return roundedrectAnimGroup
  }
  
  func depressingAnimation(fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, fromScale: CGFloat, toScale: CGFloat) -> CAAnimation{
    let radiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
    radiusAnimation.fromValue = fromRadius
    radiusAnimation.toValue = toRadius
    
    let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
    opacityAnimation.fromValue = fromOpacity
    opacityAnimation.toValue = toOpacity
    
    let scaleAnimation = CABasicAnimation(keyPath: "transform")
    scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(fromScale, fromScale, 1))
    scaleAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(0.98, 0.98, 1))
    
    let groupAnimation = CAAnimationGroup()
    groupAnimation.duration = 0.15
    groupAnimation.timingFunction = CAMediaTimingFunction(name: "easeOut")
    groupAnimation.removedOnCompletion = false
    groupAnimation.fillMode = kCAFillModeForwards
    groupAnimation.animations = [radiusAnimation, opacityAnimation, scaleAnimation]
    
    return groupAnimation
  }
  
  
  //MARK: - Bezier Path
  
  func circlePath(frame:CGRect) -> UIBezierPath {
    return UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
  }
		
  func rectanglePath(frame:CGRect) -> UIBezierPath{
    return UIBezierPath(roundedRect:CGRectMake(0, 0, buttonSize*0.6, 4), cornerRadius:3)
  }


}
