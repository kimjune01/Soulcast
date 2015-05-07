//
//  ControlBarVC.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

class IncomingVC: UIViewController {
  
  var barHeight:CGFloat = 1
  var shouldPlayNext = true
  var playPauseButton:UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.frame = CGRectMake(0, screenHeight - barHeight, screenWidth, barHeight)
    view.backgroundColor = UIColor.blueColor()
    soulCatcher.delegate = self
    soulStack.delegate = self
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "soulDidFinishPlaying:", name: "soulDidFinishPlaying", object: nil)
    
    addPlayPauseButton()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    printline("incomingVC did appear!!!")
    
    
  }
  
  func addPlayPauseButton() {
    playPauseButton = UIButton(frame: view.bounds)
    playPauseButton.backgroundColor = UIColor.greenColor()
    playPauseButton.addTarget(self, action: "didTapPlayPauseButton:", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(playPauseButton)
  }
  
  func didTapPlayPauseButton(button:UIButton) {
    
    soulStack.reload()
    button.backgroundColor = UIColor.blueColor()
    
  }
  
  func startDownloadingIncomingSouls() {
    if let topSoul = soulStack.top() {
      catchIfBlank(topSoul)
    }
  }
  
  func startPlayingIncomingSouls() {
    //TODO: wait 1.7 seconds between each playing, fade in/out.
    if shouldPlayNext {
      if soulStack.top()?.localURL != nil {
        dispatch_async(dispatch_get_main_queue()) {
          soulPlayer.startPlaying(soulStack.pop())
          self.startDownloadingIncomingSouls()
          self.shouldPlayNext = false
        }
      } else if soulStack.isEmpty() {
        playPauseButton.backgroundColor = UIColor.blueColor()
      }
      
      
    }
  }
  
  func soulDidFinishPlaying(soul:Soul) {
    shouldPlayNext = true
    startPlayingIncomingSouls()
    //pop and start downloading again when soul did finish playing
  }

  
  func catchIfBlank(emptySoul:Soul) {
    if emptySoul.localURL == nil {
      soulCatcher.catch(incomingSoul: emptySoul)
    }
  }
  
}

extension IncomingVC: SoulCatcherDelegate {
  
  func soulDidStartToDownload(soul:Soul) {
    //
  }
  func soulDidFinishDownloading(soul: Soul) {
    soulStack.findByKeyAndUpdate(soul)
    //now ready to play.
    startPlayingIncomingSouls()
  }
  
  func soulDidFailToDownload() {
    //
  }
  
  func soulIsDownloading(progress: Float) {
    //
  }
}

extension IncomingVC: SoulStackDelegate {
  func stackDidFinishReloading() {
    printline("soulStack.stack.count: \(soulStack.stack.count)")
    startDownloadingIncomingSouls()
    //now ready to download the first one.
  }
}
