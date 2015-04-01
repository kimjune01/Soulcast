//
//  OutgoingButtonVC.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit


class OutgoingButtonVC: UIViewController {
  
  var buttonSize:CGFloat = screenWidth * 2/3
  var outgoingButton: SimpleOutgoingButton!
  var outgoingSoul:Soul?
  var recordingStartTime:NSDate!
  var soulRecorder = SoulRecorder()
  var soulPlayer = SoulPlayer()
  var displayLink: CADisplayLink!
  
  var oscilloscope = TPOscilloscopeLayer(audioController: audioController)

  override func viewDidLoad() {
    super.viewDidLoad()
    addDisplayLink()
    addOscilloscope()
    addOutgoingButton()
    configureAudio()
  }
  
  override func viewDidAppear(animated: Bool) {
    //requestStartRecording()
  }

  func configureAudio() {
    soulRecorder.delegate = self
    soulRecorder.setup()
    soulPlayer.delegate = self
    var error:NSError?
    let result = audioController.start(&error)
    dump(error)
  }
  
  func addOutgoingButton() {
    view.frame = CGRectMake((screenWidth - buttonSize)/2, screenHeight - buttonSize, buttonSize, buttonSize)
    outgoingButton = SimpleOutgoingButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
    //TODO: simplest implementation first.
    //TODO: make pixel perfect.
    //outgoingButton.addTarget(self, action: "outgoingButtonTouchedDown:", forControlEvents: UIControlEvents.TouchDown)
    outgoingButton.addTarget(self, action: "outgoingButtonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
    //outgoingButton.addTarget(self, action: "outgoingButtonTouchDraggedExit:", forControlEvents: UIControlEvents.TouchDragExit)
    
    view.addSubview(outgoingButton)
  }
  
  func outgoingButtonTouchedDown(button:UIButton) {
    println("outgoingButtonTouchedDown")
    outgoingButton.buttonState = .Recording
    requestStartRecording()
  }
  
  func outgoingButtonTouchedUpInside(button:UIButton) {
    println("outgoingButtonTouchedUpInside")
//    outgoingButton.buttonState = .Enabled
//    requestFinishRecording()
    requestStartRecording()
  }
  
  func outgoingButtonTouchDraggedExit(button:UIButton) {
    println("outgoingButtonTouchDraggedExit")
    outgoingButton.buttonState = .Enabled
    requestFinishRecording()
  }
  
  func addDisplayLink() {
    displayLink = CADisplayLink(target: self, selector: "displayLinkFired:")
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }
  
  func displayLinkFired(link:CADisplayLink) {
    if soulRecorder.state == .RecordingStarted || soulRecorder.state == .RecordingLongEnough {
      incrementRecordingIndicator()
    }
    
  }
  
  func addOscilloscope() {
    oscilloscope.frame = CGRect(x: buttonSize*0.05, y:buttonSize*0.05, width: buttonSize*0.9, height: buttonSize*0.9)
    oscilloscope.lineColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
    view.layer.addSublayer(oscilloscope)
    audioController.addInputReceiver(oscilloscope)
    oscilloscope.start()
  }
  
  func incrementRecordingIndicator() {
    //TODO: query soulRecorder to update UI.
    let progress = Float(soulRecorder.displayCounter) / Float(soulRecorder.maximumRecordDuration) / 60
    println("progress: \(progress)")
  }
  
  func resetRecordingIndicator() {
    //animate alpha = 0 ease out, upom completion, stroke = 0
    //TODO:
  }
  
  func requestStartRecording() {
    recordingStartTime = NSDate()
    soulRecorder.pleaseStartRecording()
    
  }
  
  func requestFinishRecording() {
    soulRecorder.pleaseStopRecording()
    //replay, save, change ui to disabled.
    
  }
  
  func playbackSoul(localSoul:Soul) {
    println("playbackSoul localSoul:\(localSoul)")
    soulPlayer.localSoul = localSoul
    soulPlayer.startPlaying()
  }
  
  func disableButtonUI() {
    
  }
  
  func enableCancel() {
    //turn button action into a cancel, where it resets everything.
  }
  
  func disableCancel() {
    
  }
  
  func turnButtonTintDud() {
    
  }
  
  func turnButtonTintRecordingLongEnough() {
    
  }
  
  func turnButtonTintFinished() {
    
  }
  
  func animateNegativeShake() {
    //left to right a couple times, disable button in the meanwhile.
  }
  
}

extension OutgoingButtonVC: SoulRecorderDelegate {
  func soulDidStartRecording() {
    turnButtonTintDud()
  }
  
  func soulDidFailToRecord() {
    //negative animation, go back to being enabled
    animateNegativeShake()
  }
  
  func soulDidReachMinimumDuration() {
    turnButtonTintRecordingLongEnough()
  }
  
  func soulDidFinishRecording(newSoul: Soul) {
    resetRecordingIndicator()
    playbackSoul(newSoul)
    //enableCancel()
    println("soulDidFinishRecording newSoul: \(newSoul)")
  }
}

extension OutgoingButtonVC: SoulPlayerDelegate {
  func soulDidFinishPlaying() {
    //upload unless user cancels.
    //disableCancel()
  }
  func soulDidFailToPlay() {
    //
  }
}
