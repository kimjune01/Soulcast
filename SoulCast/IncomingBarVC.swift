//
//  ControlBarVC.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

class IncomingBarVC: UIViewController {
  
  var barHeight:CGFloat = 50
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.frame = CGRectMake(0, screenHeight - barHeight, screenWidth, barHeight)
    view.backgroundColor = UIColor.blueColor()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  
}
