//
//  ViewController.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let mapVC = MapVC()
  let incomingVC = IncomingBarVC()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addMapVC()
    addContolBarVC()
  }
  
  func addMapVC() {
    addChildViewController(mapVC)
    view.addSubview(mapVC.view)
    mapVC.didMoveToParentViewController(self)
  }
  
  func addContolBarVC() {
    addChildViewController(incomingVC)
    view.addSubview(incomingVC.view)
    incomingVC.didMoveToParentViewController(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

