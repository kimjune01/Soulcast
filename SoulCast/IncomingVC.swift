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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.frame = CGRectMake(0, screenHeight - barHeight, screenWidth, barHeight)
    view.backgroundColor = UIColor.blueColor()
    soulCatcher.delegate = self
    soulStack.delegate = self
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "soulDidFinishPlaying:", name: "soulDidFinishPlaying", object: nil)
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    printline("incomingVC did appear!!!")
    soulStack.reload()
    
  }
  
  func startDownloadingIncomingSouls() {
    if let topSoul = soulStack.top() {
      downloadIfBlank(topSoul)
    }
  }
  
  func startPlayingIncomingSouls() {
    //if allowed
    if shouldPlayNext {
      if soulStack.top()?.localURL != nil {
        soulPlayer.startPlaying(soulStack.pop())
      }
      startDownloadingIncomingSouls()
      shouldPlayNext = false
    }
    
  }
  
  func soulDidFinishPlaying(soul:Soul) {
    shouldPlayNext = true
    startPlayingIncomingSouls()
    //pop and start downloading again when soul did finish playing
  }

  
  func downloadIfBlank(emptySoul:Soul) {
    soulCatcher.startDownloadingAudioFrom(incomingSoul: emptySoul)
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
