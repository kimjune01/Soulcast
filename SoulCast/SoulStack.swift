//
//  SoulStack.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-04-04.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

let soulStack = SoulStack()

class SoulStack: NSMutableArray {
   //TODO: soulCatcher puts stuff in the stack, then disappears once the user listens to it
  
  override convenience init() {
    self.init()
    //TODO: load from realm, previous souls.
  }
  
  
}
