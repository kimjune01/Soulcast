//
//  MapViewController.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit
import MapKit

protocol mapVCDelegate {
  func mapVCDidChangeCastRadius(castRadius:Double)
}

class MapVC: UIViewController {
  
  let mapView = MKMapView()
  let locationManager = CLLocationManager()
  var permissionView: UIView!
  var latestLocation: CLLocation?
  var userSpan: MKCoordinateSpan?
  var originalRegion: MKCoordinateRegion?
  
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
      userSpan = MKCoordinateSpanMake(
        locationDictionary["latitudeDelta"] as Double,
        locationDictionary["longitudeDelta"] as Double)
      latestLocation = CLLocation(
        latitude: locationDictionary["latitude"] as Double,
        longitude: locationDictionary["longitude"] as Double)
    } else {
      userSpan = MKCoordinateSpanMake(0.3, 0.3)
    }
  }
  
  func saveRegionDataToUserDefaults() {
    if let location = latestLocation {
      let locationDictionary:NSDictionary = NSDictionary(dictionary: [
        "latitude": location.coordinate.latitude as Double,
        "longitude": location.coordinate.longitude as Double])
      NSUserDefaults.standardUserDefaults().setValue(locationDictionary, forKey: "locationDictionary")
    }
    if let span = userSpan {
      let spanDictionary: NSDictionary = NSDictionary(dictionary: [
        "latitudeDelta": span.latitudeDelta as Double,
        "longitudeDelta": span.longitudeDelta as Double])
      NSUserDefaults.standardUserDefaults().setValue(spanDictionary, forKey: "locationDictionary")
    }
  }

  func addMap() {
    mapView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height*0.9)
    mapView.mapType = .Satellite
    mapView.scrollEnabled = false
    mapView.rotateEnabled = false
    mapView.zoomEnabled = false
    mapView.showsUserLocation = true
    if let location = latestLocation {
      if let span = userSpan {
        mapView.setRegion(MKCoordinateRegionMake(location.coordinate, span), animated: true)
      }
    }
    mapView.delegate = self
    view.addSubview(mapView)

    //
    addPinchGestureRecognizer()
  }
  
  func addPinchGestureRecognizer() {
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "didPanOnMapView:")
    mapView.addGestureRecognizer(pinchRecognizer)
  }
  
  func didPanOnMapView(pinchRecognizer:UIPinchGestureRecognizer) {
    println("pinchRecognizer.scale: \(pinchRecognizer.scale)")
    
    switch pinchRecognizer.state {
    case .Began:
      originalRegion = mapView.region
    case .Changed:
      fallthrough
    case .Ended:
      var latitudeDelta = Double(originalRegion!.span.latitudeDelta) / Double(pinchRecognizer.scale)
      var longitudeDelta = Double(originalRegion!.span.longitudeDelta) / Double(pinchRecognizer.scale);
      latitudeDelta = max(min(latitudeDelta, 10), 0.01);
      longitudeDelta = max(min(longitudeDelta, 10), 0.01);
      userSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
      self.mapView.setRegion(MKCoordinateRegionMake(originalRegion!.center, userSpan!), animated: false)
      break
    default:
    break
    }
    
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
    let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: userSpan!)
    mapView.setRegion(mapRegion, animated: true)
    
  }
  
  func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
    //
  }
  
  func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
    //
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
    saveRegionDataToUserDefaults()
  }
  
  func restartLocationUpdates(timer: NSTimer) {
    timer.invalidate()
    locationManager.startUpdatingLocation()
    
    
  }
  
}
