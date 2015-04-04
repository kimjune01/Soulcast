
let deviceManager = DeviceManager()

class DeviceManager: NSObject {
  
  func registerDevice(#device: Device) {
    registerLocally(token: device.token)
    registerDeviceWithServer(device)
  }
  
  private func registerDeviceWithServer (device: Device) {
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
  
  private func registerLocally(#token: String) {
    NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
  }

}
