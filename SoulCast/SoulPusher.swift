//
//  SoulPusher.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-04-04.
//  Copyright (c) 2015 June. All rights reserved.
//

///Pushes a soul to a device
class SoulPusher: NSObject {

  //TODO: a function that takes in a device and a soul, returns a Bool regarding its success.
  
  //TODO: a function that takes in a device, sends a silent push, and determines whether it can catch, returns Bool
  
  func localToken() -> String {
    return NSUserDefaults.standardUserDefaults().valueForKey("token") as String
  }
}
