//
//  SoulPlayer.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

protocol SoulPlayerDelegate {
  func soulDidFinishPlaying()
  func soulDidFailToPlay()
}

class SoulPlayer: NSObject {
  var localSoul:Soul!
  var player: AEAudioFilePlayer!
  var delegate: SoulPlayerDelegate!

  func startPlaying() {
    var error:NSError?
    player = AEAudioFilePlayer.audioFilePlayerWithURL(NSURL(fileURLWithPath: localSoul.localURL!), audioController: audioController, error: &error) as? AEAudioFilePlayer
    if let e = error {
      println("oh noes! playAudioAtPath error: \(e)")
      delegate.soulDidFailToPlay()
      return
    }
    player?.removeUponFinish = true
    player?.completionBlock = {
      self.delegate.soulDidFinishPlaying()
      self.reset()
    }
    audioController.addChannels([player])
  }
  
  
  
  func reset() {
    audioController.removeChannels([player])
    
  }
  
}
