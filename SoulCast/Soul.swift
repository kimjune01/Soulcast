//
//  Soul.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

let audioController = AEAudioController(audioDescription: AEAudioController.nonInterleaved16BitStereoAudioDescription(), inputEnabled: true)

class Soul: NSObject {
  var s3Key:NSString?
  var localURL:NSString?
  var secondsSince1970:Int?
  var longitude:NSString?
  var latitude:NSString?
  //length
  //origin location
  //cast radius
  //origin token
  
  func toParams(#type:String) -> NSDictionary {
    let wrapperParams = NSMutableDictionary()
    wrapperParams["type"] = type
    let contentParams = NSMutableDictionary()
    wrapperParams["content"] = contentParams
    contentParams["s3Key"] = s3Key
    if let epoch = secondsSince1970 {
      contentParams["epoch"] = String(epoch)
    }
    contentParams["longitude"] = longitude
    contentParams["latitude"] = latitude
    
    return wrapperParams
  }
  
  class func fromParams(incomingParams:NSDictionary) -> Soul {
    println("fromParams incomingParams: \(incomingParams)")
    var incomingSoul = Soul()
    if incomingParams["content"] as? String == "incoming" {
      if let contentParams = incomingParams["content"] as? NSDictionary {
        incomingSoul.s3Key = contentParams["s3Key"] as? String
        incomingSoul.secondsSince1970 = contentParams["epoch"] as? Int
        incomingSoul.longitude = contentParams["longitude"] as? String
        incomingSoul.latitude = contentParams["latitude"] as? String
      }
    } else {
      assert(false, "Attempted to interpret a non-incoming Soul!")
    }
    return incomingSoul
  }
}
