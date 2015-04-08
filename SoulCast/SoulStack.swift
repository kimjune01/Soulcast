//
//  SoulStack.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-04-04.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

protocol SoulStackDelegate {
  func stackDidFinishReloading()
}

let soulStack = SoulStack()

class SoulStack: NSObject {
  
  var stack:[Soul] = [] //has no localURL.
  var delegate: SoulStackDelegate?
  
  func top() -> Soul? {
    if stack.count > 0 {
      return stack.last
    }
    return nil
  }
  
  func pop() -> Soul? {
    //TODO: download audio on the upcoming soul.
    return stack.pop()
  }
  
  func push(soul:Soul) {
    stack.append(soul)
  }
  
  func reload() {
    let getSoulsInAreaURLString = serverURL + "api/souls.json"
    let params = Device.localDevice.toParams()
    networkRequestManager().GET(getSoulsInAreaURLString, parameters: params, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
      var souls: [Soul] = []
      for eachSoulParams in response as [NSDictionary] {
        let eachSoul = Soul.fromContentParams(eachSoulParams)
        souls.append(eachSoul)
      }
      self.stack = self.sortByRelevance(souls)
      self.delegate?.stackDidFinishReloading()
      }) { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
        //
        assert(false, "GET SoulsInArea FAIL: \(error)")
    }
  }
  
  func sortByRelevance(souls:[Soul]) -> [Soul] {
    //TODO:
    return souls
  }
  
  func findByKeyAndUpdate(soul:Soul) {
    for eachSoul in stack {
      if eachSoul.s3Key == soul.s3Key {
        eachSoul.localURL = soul.localURL
        break
      }
    }
    
  }
  
  // Upon querying the database, the souls are ordered in Reddit algorithm.
  // then the top soul starts playing and is popped off the stack simultaneously.
  // upon finishing playing the soul, the next soul on the stack is played.
  // each incoming soul is pushed on top of the stack.
  
  //query to refresh once every hour.
  
}
