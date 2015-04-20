//
//  ControlBarVC.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

class IncomingVC: UIViewController {
  
  var barHeight:CGFloat = 50
  var shouldPlayNext = true
  var playButton:UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.frame = CGRectMake(0, screenHeight - barHeight, screenWidth, barHeight)
    view.backgroundColor = UIColor.blueColor()
    soulCatcher.delegate = self
    soulStack.delegate = self
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "soulDidFinishPlaying:", name: "soulDidFinishPlaying", object: nil)
    
    addPlayButton()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    printline("incomingVC did appear!!!")
    
    
  }
  
  func addPlayButton() {
    playButton = UIButton(frame: view.bounds)
    playButton.backgroundColor = UIColor.whiteColor()
    playButton.addTarget(self, action: "didTapPlayButton:", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(playButton)
  }
  
  func didTapPlayButton(button:UIButton) {
    soulStack.reload()
    button.hidden = true
    
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
        playButton.hidden = false
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
