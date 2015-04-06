//
//  SoulPlayer.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

protocol SoulPlayerDelegate {
  func soulDidFinishPlaying(localSoul:Soul)
  func soulDidFailToPlay()
}

class SoulPlayer: NSObject {
  var tempSoul: Soul!
  var player: AEAudioFilePlayer!
  var delegate: SoulPlayerDelegate?

  func startPlaying(soul:Soul!) {
    var error:NSError?
    tempSoul = soul
    println("soul.localURL: \(soul.localURL!)")
    player = AEAudioFilePlayer.audioFilePlayerWithURL(NSURL(fileURLWithPath: soul.localURL!), audioController: audioController, error: &error) as? AEAudioFilePlayer
    if let e = error {
      println("oh noes! playAudioAtPath error: \(e)")
      delegate?.soulDidFailToPlay()
      return
    }
    player?.removeUponFinish = true
    player?.completionBlock = {
      self.delegate?.soulDidFinishPlaying(self.tempSoul)
      self.reset()
    }
    audioController.addChannels([player])
  }

  
  func remoteUrlFromKey(NSString) -> NSString {
    
    return ""
  }
  
  func reset() {
    audioController.removeChannels([player])
    
  }
  
}
