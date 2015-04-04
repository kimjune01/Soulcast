//
//  ViewController.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

  var childVCs:[UIViewController]!
  let outgoingVC = OutgoingVC()
  let mapVC = MapVC()
  let incomingBarVC = IncomingBarVC()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addChildVCs()
    
  }
  
  func addChildVCs() {
    outgoingVC.delegate = self
    childVCs = [mapVC, incomingBarVC, outgoingVC]
    
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

extension ViewController: OutgoingVCDelegate {
  func outgoingCastRadius() -> Double {
    println("outgoingCastRadius: mapVC.userSpan!.latitudeDelta: \(mapVC.userSpan!.latitudeDelta)")
    return mapVC.userSpan!.latitudeDelta
  }
  
  func outgoingLongitude() -> Double {
    return mapVC.latestLocation!.coordinate.longitude
  }
  
  func outgoingLatitude() -> Double {
    return mapVC.latestLocation!.coordinate.latitude
  }
  
  func outgoingDidStart() {
    //
  }
  
  func outgoingDidStop() {
    //
  }
}

