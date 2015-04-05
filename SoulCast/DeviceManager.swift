
let deviceManager = DeviceManager()

class DeviceManager: NSObject {
  
  func registerDeviceLocally(#device: Device) {
    NSUserDefaults.standardUserDefaults().setValue(device.token, forKey: "token")
  }
  
  func register(device: Device) {    //do once per lifetime.
    struct Holder {
      static var tempDevice = device
    }
    AWSSNS.defaultSNS().createPlatformEndpoint(self.createPlatformEndpointInput(device)).continueWithSuccessBlock { (task:BFTask!) -> AnyObject! in
      let endpointResponse = task.result as AWSSNSCreateEndpointResponse
      Holder.tempDevice.arn = endpointResponse.endpointArn
      self.registerWithServer(Holder.tempDevice)
      return nil
    }
  }
  
  private func registerWithServer(device:Device) {
    let manager = AFHTTPRequestOperationManager()
    manager.requestSerializer = AFJSONRequestSerializer(writingOptions: NSJSONWritingOptions.PrettyPrinted)
    manager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.MutableContainers)
    manager.POST(serverURL + newDeviceSuffix, parameters: device.toParams(), success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
      //
      println("registerDevice POST Success! operation: \(operation), response: \(response)")
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        //
        println("registerDevice POST Failure! operation: \(operation), error: \(error.localizedDescription)")
    }
  }
  
  func createPlatformEndpointInput(device:Device) -> AWSSNSCreatePlatformEndpointInput{
    let input = AWSSNSCreatePlatformEndpointInput()
    input.token = device.token
    return input
    
  }
  

}
