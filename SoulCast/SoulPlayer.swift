//
//  SoulPlayer.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

enum PlayerState {
  case Unknown
  case Playing
  case Paused
  case Finished
  case Err
}

class SoulPlayer: NSObject {
  var localSoul:Soul!
  var soulPlayerState:PlayerState = .Unknown {
    didSet{
      switch (oldValue, soulPlayerState) {
      case (.Unknown, .Playing):
        startPlaying()
      case (.Playing, .Paused):
        pause()
      case (.Paused, .Playing):
        resume()
      case (.Playing, .Finished):
        reset()
      case (let x, .Err):
        println("soulPlayerState x.hashValue: \(x.hashValue)")
      default:
        assert(false, "OOPS!!!")
      }
    }
  }

  func startPlaying() {
    var error:NSError?
    let player = AEAudioFilePlayer.audioFilePlayerWithURL(localSoul.localURL!, audioController: audioController, error: &error) as? AEAudioFilePlayer
    if let e = error {
      println("oh noes! playAudioAtPath error: \(e)")
      soulPlayerState = .Err
      return
    }
    player?.removeUponFinish = true
    player?.completionBlock = {
      //
    }
    audioController.addChannels(NSArray(object: player!))
  }
  
  func pause() {
    
  }
  
  func resume() {
    
  }
  
  func reset() {
    
  }
  
}
