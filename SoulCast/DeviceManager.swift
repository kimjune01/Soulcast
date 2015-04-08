
let deviceManager = DeviceManager()

class DeviceManager: NSObject {
  var tempDevice: Device!

  
  private func registerDeviceLocally(device: Device) {
    NSUserDefaults.standardUserDefaults().setValue(device.token, forKey: "token")
  }
  
  func register(device: Device) {    //do once per lifetime.
    registerDeviceLocally(device)
    tempDevice = device
    AWSSNS.defaultSNS().createPlatformEndpoint(self.createPlatformEndpointInput(device)).continueWithBlock { (task:BFTask!) -> AnyObject! in
      if task.error == nil {
        let endpointResponse = task.result as AWSSNSCreateEndpointResponse
        self.tempDevice.arn = endpointResponse.endpointArn
        self.registerWithServer(self.tempDevice)
      } else if task.error.domain == AWSSNSErrorDomain{
        if let errorInfo = task.error.userInfo as NSDictionary! {
          if errorInfo["Code"] as String! == "InvalidParameter" {
            //
          }
        }
      } else {
        self.registerWithServer(self.tempDevice) //!!
        assert(false, "AWSSNS is complaining! To investigate: \(task.error.description)")
      }
      return nil
      
    }
//    AWSSNS.defaultSNS().createPlatformEndpoint(self.createPlatformEndpointInput(device)).continueWithSuccessBlock { (task:BFTask!) -> AnyObject! in
//      println("createPlatformEndpoint task: \(task)")
//      if task.error == nil {
//        let endpointResponse = task.result as AWSSNSCreateEndpointResponse
//        self.tempDevice.arn = endpointResponse.endpointArn
//        self.registerWithServer(self.tempDevice)
//      } else {
//        
//        println("task.error: \(task.error)")
//      }
//      return nil
//    }
  }
  
  func registerWithServer(device:Device) {
    networkRequestManager().POST(serverURL + newDeviceSuffix, parameters: device.toParams(), success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
      // get ID and update to device
      self.updateLocalDeviceID((response as NSDictionary)["id"] as Int)
      printline("registerDevice POST Success! operation: \(operation), response: \(response)")
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        //
        println("registerDevice POST Failure! operation: \(operation), error: \(error.localizedDescription)")
    }
  }
  
  func createPlatformEndpointInput(device:Device) -> AWSSNSCreatePlatformEndpointInput{
    let input = AWSSNSCreatePlatformEndpointInput()
    input.token = device.token
    input.platformApplicationArn = SNSPlatformARN
    return input
    
  }
  
  func updateLocalDeviceID(id:Int) {
    let updatingDevice = Device.localDevice
    updatingDevice.id = id
    Device.localDevice = updatingDevice

  }
  
  func updateDeviceRegion(#latitude:Double, longitude:Double, radius:Double) {
    let updatingDevice = Device.localDevice
    updatingDevice.latitude = latitude
    updatingDevice.longitude = longitude
    updatingDevice.radius = radius
    Device.localDevice = updatingDevice
    
    if let deviceID = updatingDevice.id {
      let patchURLString = serverURL + "/api/devices/" + String(deviceID) + ".json"
      networkRequestManager().PATCH(patchURLString, parameters: updatingDevice.toParams(), success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        //printline("updateDeviceRegion PATCH response: \(response)")
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
          println("error: \(error)")
          assert(false, "updateDeviceRegion PATCH failed!")
          
      }
    }
  }

  
}
