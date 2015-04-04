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
  var epoch:Int?
  var longitude:Double?
  var latitude:Double?
  var castRadius: Double?
  //length
  //cast radius
  //origin token
  
  func toParams(#type:String) -> NSDictionary {
    let wrapperParams = NSMutableDictionary()
    wrapperParams["type"] = type
    let contentParams = NSMutableDictionary()
    wrapperParams["soul"] = contentParams
    
    contentParams["s3Key"] = s3Key
    contentParams["epoch"] = epoch
    contentParams["longitude"] = longitude
    contentParams["latitude"] = latitude
    contentParams["castRadius"] = castRadius
    
    return wrapperParams
  }
  
  
  class func fromParams(incomingParams:NSDictionary) -> Soul {
    println("fromParams incomingParams: \(incomingParams)")
    var incomingSoul = Soul()
    if incomingParams["type"] as? String == "incoming" {
      if let contentParams = incomingParams["soul"] as? NSDictionary {
        incomingSoul.s3Key = contentParams["s3Key"] as? String
        incomingSoul.epoch = contentParams["epoch"] as? Int
        incomingSoul.longitude = contentParams["longitude"] as? Double
        incomingSoul.latitude = contentParams["latitude"] as? Double
        incomingSoul.castRadius = contentParams["castRadius"] as? Double
      }
    } else {
      assert(false, "Attempted to interpret a non-incoming Soul!")
    }
    return incomingSoul
  }
}
