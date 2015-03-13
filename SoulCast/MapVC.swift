//
//  MapViewController.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
  
  let mapView = MKMapView()
  let locationManager = CLLocationManager()
  var permissionView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addMap()
    monitorLocation()
  }
  
  override func viewDidAppear(animated: Bool) {
    manualAskLocationPermission()
  }

  func addMap() {
    mapView.frame = view.frame
    mapView.delegate = self
    view.addSubview(mapView)

  }
  
  func monitorLocation() {
    locationManager.delegate = self
    
    locationManager.startUpdatingLocation()
    mapView.showsUserLocation = true
  }
  
  func manualAskLocationPermission() {
    if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
      //ask manually for permission.
      let locationAlert = UIAlertController(title: "Allow location?", message: "SoulCast needs it to listen to those around you", preferredStyle: .Alert)
      let cancelAction = UIAlertAction(title: "cancel", style: .Default, handler: { (action:UIAlertAction!) -> Void in
        //TODO: overlay stuff on MapView, allowing them to ask location permission again.
        
      })
      let successAction = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
        self.systemAskLocationPermission()
      })
      locationAlert.addAction(cancelAction)
      locationAlert.addAction(successAction)
      
    }
    

  }
  
  func addPermissionView() {
    permissionView = UIView(frame: mapView.frame)
    permissionView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.3)

    let permissionLabel = UILabel(frame: CGRectMake(0, 0, mapView.frame.size.width, 200))
    permissionLabel.center = mapView.center
    permissionLabel.text = "ALLOW LOCATION PERMISSION"
    permissionLabel.textAlignment = .Center
    permissionLabel.font = UIFont(name: "Helvetica", size: 20)
    permissionLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.85)
    permissionView.addSubview(permissionLabel)
    
    let permissionTapRecognizer = UITapGestureRecognizer(target: self, action: "permissionViewTapped:")
    permissionView.addGestureRecognizer(permissionTapRecognizer)
    
    view.addSubview(permissionView)
  }
  
  func permissionViewTapped(recognizer:UIGestureRecognizer) {
    recognizer.removeTarget(self, action: "permissionViewTapped:")
    manualAskLocationPermission()
  }
  
  func systemAskLocationPermission() {
    if locationManager.respondsToSelector("requestAlwaysAuthorization") {
      locationManager.requestAlwaysAuthorization()
    }
    if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
      locationManager.requestWhenInUseAuthorization()
    }

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
}

extension MapVC: MKMapViewDelegate {
  
}

extension MapVC: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    //update location
    println("locations.last: \(locations.last?.description)")
  }
}