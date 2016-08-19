//
//  SoulPlayer.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

let soulPlayer = SoulPlayer()

class SoulPlayer: NSObject {
  var tempSoul: Soul!
  var player: AEAudioFilePlayer!
  
  func startPlaying(soul:Soul!) {
    var error:NSError?
    tempSoul = soul
    printline("soul.localURL: \(soul.localURL!)")
    player = AEAudioFilePlayer.audioFilePlayerWithURL(NSURL(fileURLWithPath: soul.localURL! as String), audioController: audioController, error: &error) as? AEAudioFilePlayer
    if let e = error {
      printline("oh noes! playAudioAtPath error: \(e)")
      NSNotificationCenter.defaultCenter().postNotificationName("soulDidFailToPlay", object: self.tempSoul)
      return
    }
    player?.removeUponFinish = true
    player?.completionBlock = {
      NSNotificationCenter.defaultCenter().postNotificationName("soulDidFinishPlaying", object: self.tempSoul)
      self.reset()
    }
    audioController.addChannels([player])
  }

  
  func remoteUrlFromKey(_: NSString) -> NSString {
    
    return ""
  }
  
  func reset() {
    audioController.removeChannels([player])
    
  }
  
}
