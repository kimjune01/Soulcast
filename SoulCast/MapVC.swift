

import UIKit
import MapKit

protocol mapVCDelegate {
  func mapVCDidChangeradius(radius:Double)
}

class MapVC: UIViewController {
  
  let mapView = MKMapView()
  let locationManager = CLLocationManager()
  var permissionView: UIView!
  var latestLocation: CLLocation? {
    get {
      if let savedLatitude = Device.localDevice.latitude {
        if let savedLongitude = Device.localDevice.longitude {
          return CLLocation(latitude: savedLatitude, longitude: savedLongitude)
        }
      }
      return CLLocation(latitude: 49.2812277842772, longitude: -122.956074765067)
    }
    set (newValue) {
      let updatingDevice = Device.localDevice
      updatingDevice.latitude = newValue?.coordinate.latitude
      updatingDevice.longitude = newValue?.coordinate.longitude
      Device.localDevice = updatingDevice
    }
  }
  var userSpan: MKCoordinateSpan! {
    get {
      if let savedRadius = Device.localDevice.radius {
        return MKCoordinateSpanMake(savedRadius, savedRadius)
      } else {
        return MKCoordinateSpanMake(0.3, 0.3)
      }
    }
    set (newValue) {
      let updatingDevice = Device.localDevice
      updatingDevice.radius = newValue.latitudeDelta
      Device.localDevice = updatingDevice
    }
  }
  var originalRegion: MKCoordinateRegion?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addMap()
    monitorLocation()
  }
  
  override func viewDidAppear(animated: Bool) {
    manualAskLocationPermission()
  }
  
  
  func saveRegionData() {
    if let location = latestLocation {
      if let span = userSpan {
        deviceManager.updateDeviceRegion(latitude: location.coordinate.latitude as Double, longitude: location.coordinate.longitude as Double, radius: span.latitudeDelta as Double)
      }
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
    
    addPinchGestureRecognizer()
  }
  
  func addPinchGestureRecognizer() {
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "didPanOnMapView:")
    mapView.addGestureRecognizer(pinchRecognizer)
  }
  
  func didPanOnMapView(pinchRecognizer:UIPinchGestureRecognizer) {
    switch pinchRecognizer.state {
    case .Began:
      originalRegion = mapView.region
    case .Changed:
      var latitudeDelta = Double(originalRegion!.span.latitudeDelta) / Double(pinchRecognizer.scale)
      var longitudeDelta = Double(originalRegion!.span.longitudeDelta) / Double(pinchRecognizer.scale);
      latitudeDelta = max(min(latitudeDelta, 10), 0.005);
      longitudeDelta = max(min(longitudeDelta, 10), 0.005);
      userSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
      self.mapView.setRegion(MKCoordinateRegionMake(originalRegion!.center, userSpan!), animated: false)
    case .Ended:
      saveRegionData()
      
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
}

extension MapVC: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    //update location
    if let previousLocation = latestLocation {
      let distance = (locations.last as? CLLocation)?.distanceFromLocation(previousLocation)
      if distance > 50 {
        
      } else {
        //do nothing interesting
      }
    }
    manager.stopUpdatingLocation()
    NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "restartLocationUpdates:", userInfo: nil, repeats: false)
    latestLocation = locations.last as? CLLocation
    saveRegionData()
  }
  
  func restartLocationUpdates(timer: NSTimer) {
    timer.invalidate()
    locationManager.startUpdatingLocation()
    
    
  }
  
}
