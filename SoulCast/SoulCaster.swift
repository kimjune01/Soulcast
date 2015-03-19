//
//  SoulCaster.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

enum UploaderState {
  case Unknown
  case Uploading
  case Failed
  case Finished
}

class SoulCaster: NSObject {
  
  var localSoul:Soul!
  
  var soulCasterState:UploaderState = .Unknown {
    didSet {
      switch (oldValue, soulCasterState) {
      case (.Unknown, .Uploading):
        startUploading()
      case (.Uploading, .Finished):
        notifyDelegate()
      case (.Finished, .Unknown):
        reset()
      case (let x, .Failed):
        println("soulCasterState x.hashValue: \(x.hashValue)")
      default:
        assert(false, "OOPS!!!")
      }
    }
  }
  
  func startUploading() {
    
  }
  
  func notifyDelegate() {
    
  }
  
  func reset() {
    
  }
  
  //uploads to S3
  //calls server upon completion
  
}
