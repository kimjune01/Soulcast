import Foundation

class Device: NSObject {
  var id: Int?
  var token: String!
  var longitude: Double?
  var latitude: Double?
  var arn: String?
  
  class func localDevice() -> Device {
    let localDevice = Device()
    localDevice.token = NSUserDefaults.standardUserDefaults().valueForKey("token") as String
    if let locationDictionary: NSDictionary =
      NSUserDefaults.standardUserDefaults().valueForKey("locationDictionary") as? NSDictionary {
        localDevice.longitude = locationDictionary["longitude"] as Double?
        localDevice.latitude = locationDictionary["latitude"] as Double?
    }
    return localDevice
  }
  
  class func fromParams(incomingParams: NSDictionary) -> Device{
    var incomingDevice = Device()
    if incomingParams["type"] as? String == "incoming" {
      if let contentParams = incomingParams["device"] as? NSDictionary {
        incomingDevice.token = contentParams["token"] as? String
        incomingDevice.longitude = contentParams["longitude"] as? Double
        incomingDevice.latitude = contentParams["latitude"] as? Double
        incomingDevice.arn = contentParams["arn"] as? String
      }
    }
    
    return Device()
  }
  
  func toParams() -> NSDictionary {
    let wrapperParams = NSMutableDictionary()
    let contentParams = NSMutableDictionary()
    wrapperParams["device"] = contentParams
    contentParams["token"] = token
    if longitude != nil { contentParams["longitude"] = longitude }
    if latitude != nil { contentParams["latitude"] = latitude }
    
    return wrapperParams
  }
  

}
