//
//  ViewController.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

  let childVCs = [MapVC(), IncomingBarVC(), OutgoingButtonVC()]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addChildVCs()
  }
  
  func addChildVCs() {
    for eachChildVC in childVCs {
      addChildViewController(eachChildVC)
      view.addSubview(eachChildVC.view)
      eachChildVC.didMoveToParentViewController(self)
    }
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

