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
  var s3Key:String?
  var localURL:NSString?
  var epoch:Int?
  var longitude:Double?
  var latitude:Double?
  var radius: Double?
  var token: String?
  var device: Device?
  //length
  
  func toParams(#type:String) -> NSDictionary {
    let wrapperParams = NSMutableDictionary()
    wrapperParams["type"] = type
    let contentParams = NSMutableDictionary()
    wrapperParams["soul"] = contentParams
    
    contentParams["s3Key"] = s3Key
    contentParams["epoch"] = epoch
    contentParams["longitude"] = longitude
    contentParams["latitude"] = latitude
    contentParams["radius"] = radius
    contentParams["token"] = token
    
    return wrapperParams
  }
  
  
  class func from(#incomingParams:NSDictionary) -> Soul {
    println("fromParams incomingParams: \(incomingParams)")
    var incomingSoul = Soul()
    if incomingParams["type"] as? String == "incoming" {
      if let contentParams = incomingParams["soul"] as? NSDictionary {
        incomingSoul = Soul.fromContentParams(contentParams)
      }
    } else {
      assert(false, "Tried to interpret non-incoming params!")
    }
    return incomingSoul
  }
  
  class func fromContentParams(contentParams:NSDictionary) -> Soul {
    let contentSoul = Soul()
    contentSoul.s3Key = contentParams["s3Key"] as? String
    contentSoul.epoch = contentParams["epoch"] as? Int
    contentSoul.latitude = (contentParams["latitude"] as NSString).doubleValue
    contentSoul.longitude = (contentParams["longitude"] as NSString).doubleValue
    contentSoul.radius = (contentParams["radius"] as NSString).doubleValue
    if let deviceID = contentParams["device_id"] as? Int {
      let device = Device()
      device.id = deviceID
      contentSoul.device = device
    }
    return contentSoul
  }
  
}
