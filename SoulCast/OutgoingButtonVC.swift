//
//  OutgoingButtonVC.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

enum RecordButtonState {
  case Able
  case Recording
  case Disabled
}

class OutgoingButtonVC: UIViewController {
  
  var buttonSize:CGFloat = 80
  var outgoingButton: UIButton!
  var outgoingSoul:Soul?
  var recordingStartTime:NSDate!
  var soulRecorder = SoulRecorder()
  
  var outgoingButtonState: RecordButtonState = .Able {
    didSet {
      switch (oldValue, outgoingButtonState) {
      case (.Able, .Recording):
        requestStartRecording()
      case (.Recording, .Able):
        requestCancelRecording()
      case (.Recording, .Disabled):
        requestFinishRecording()
      case (.Disabled, .Able):
        enableButtonUI()
      default:
        assert(false, "OOOPS!!!")
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addOutgoingButton()
  }
  
  func addOutgoingButton() {
    view.frame = CGRectMake((screenWidth - buttonSize)/2, screenHeight - buttonSize, buttonSize, buttonSize)
    view.backgroundColor = UIColor.redColor()

    outgoingButton = UIButton(frame: view.frame)
    //TODO: make pixel perfect.
    outgoingButton.addTarget(self, action: "outgoingButtonTouchedDown:", forControlEvents: UIControlEvents.TouchDown)
    outgoingButton.addTarget(self, action: "outgoingButtonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
    outgoingButton.addTarget(self, action: "outgoingButtonTouchDraggedExit:", forControlEvents: UIControlEvents.TouchDragExit)
    
  }
  
  func outgoingButtonTouchedDown(button:UIButton) {
    println("outgoingButtonTouchedDown")
    outgoingButtonState = .Recording
  }
  
  func outgoingButtonTouchedUpInside(button:UIButton) {
    println("outgoingButtonTouchedUpInside")
    let timeInterval:Double = NSDate().timeIntervalSinceDate(recordingStartTime)
    println("timeInterval: \(timeInterval)")
    if timeInterval > 1 {
      outgoingButtonState = .Disabled
    } else {
      outgoingButtonState = .Able
    }
  }
  
  func outgoingButtonTouchDraggedExit(button:UIButton) {
    println("outgoingButtonTouchDraggedExit")
    outgoingButtonState = .Able
  }
  
  func requestStartRecording() {
    recordingStartTime = NSDate()
    //soulRecorder.startRecording()
    
  }
  
  func requestCancelRecording() {
    //pressed button for less than one second. reset soulRecorder
  }
  
  func requestFinishRecording() {
    //replay, save, change ui to disabled.
    disableButtonUI()
  }
  
  func enableButtonUI() {
    
  }
  
  func disableButtonUI() {
    
  }
  
  //TODO: show alert for recording less than one second.
  
  
  
  
}

extension OutgoingButtonVC: SoulRecorderDelegate {
  func soulDidFailToRecording() {
    //
  }
  
  func soulDidFinishRecording(newSoul: Soul) {
    //
  }
}
