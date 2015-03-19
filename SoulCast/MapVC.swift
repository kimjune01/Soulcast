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
  var latestLocation: CLLocation?
  var userSpan: MKCoordinateSpan?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    retrieveRegionDataFromUserDefaults()
    addMap()
    monitorLocation()
  }
  
  override func viewDidAppear(animated: Bool) {
    manualAskLocationPermission()
  }
  
  func retrieveRegionDataFromUserDefaults() {
    if let locationDictionary: NSDictionary =
      NSUserDefaults.standardUserDefaults().valueForKey("locationDictionary") as? NSDictionary {
        latestLocation = CLLocation(latitude: locationDictionary["lat"] as Double , longitude: locationDictionary["long"] as Double)
    }
    if let defaultsSpan: NSDictionary =
      NSUserDefaults.standardUserDefaults().valueForKey("spanDictionary") as? NSDictionary {
      userSpan = MKCoordinateSpanMake(defaultsSpan["latDelta"] as Double, defaultsSpan["longDelta"] as Double)
    }
  }
  
  func saveRegionDataFromUserDefaults() {
    if let location = latestLocation {
      let locationDictionary:NSDictionary = NSDictionary(dictionary: ["lat": location.coordinate.latitude as Double, "long": location.coordinate.longitude as Double])
      NSUserDefaults.standardUserDefaults().setValue(locationDictionary, forKey: "locationDictionary")
    }
    if let span = userSpan {
      let spanDictionary: NSDictionary = NSDictionary(dictionary: ["latDelta": span.latitudeDelta as Double, "longDelta": span.longitudeDelta as Double])
      NSUserDefaults.standardUserDefaults().setValue(spanDictionary, forKey: "spanDictionary")
    }
  }

  func addMap() {
    mapView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
    mapView.mapType = .Satellite
    mapView.scrollEnabled = false
    mapView.rotateEnabled = false
    mapView.zoomEnabled = true
    mapView.pitchEnabled = false
    mapView.showsUserLocation = true
    if let location = latestLocation {
      if let span = userSpan {
        mapView.setRegion(MKCoordinateRegionMake(location.coordinate, span), animated: true)
      }
    }
    mapView.delegate = self
    view.addSubview(mapView)

  }
  
  func monitorLocation() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
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
      
      presentViewController(locationAlert, animated: true, completion: { () -> Void in
        //
      })
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
  func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
    let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(0.07, 0.07))
    mapView.setRegion(mapRegion, animated: true)
    
  }
  
  //TODO: when mapkit did zoom or pinch
  //save new region.
}

extension MapVC: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    //update location
    if let previousLocation = latestLocation {
      let distance = (locations.last as? CLLocation)?.distanceFromLocation(previousLocation)
      if distance > 50 {
        //update map.
      } else {
        //do nothing interesting
      }
    }
    manager.stopUpdatingLocation()
    NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "restartLocationUpdates:", userInfo: nil, repeats: false)
    
    latestLocation = locations.last as? CLLocation
    saveRegionDataFromUserDefaults()
  }
  
  func restartLocationUpdates(timer: NSTimer) {
    timer.invalidate()
    locationManager.startUpdatingLocation()
    
    
  }
  
}