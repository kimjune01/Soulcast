import Foundation

class Device: NSObject {
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
  
  class func seedDevice() -> Device {
    let seed = Device()
    seed.token = "e35c22814ff6b5217ac3823403a59bdc958fc9e20ef865b322546b1afefd552a"
    seed.longitude = -93.2783
    seed.latitude = 44.9817
    seed.arn = "arn:aws:sns:us-east-1:503476828113:endpoint/APNS_SANDBOX/Soulcast_Development/a08b89b5-3015-3d4b-a14a-f0e657fffedb"
    return seed
  }
}
