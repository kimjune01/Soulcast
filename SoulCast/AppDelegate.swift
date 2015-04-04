//
//  AppDelegate.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

import UIKit
import CoreData

let screenWidth = UIScreen.mainScreen().bounds.width
let screenHeight = UIScreen.mainScreen().bounds.height

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var backgroundUploadSessionCompletionHandler: ()?
  var backgroundDownloadSessionCompletionHandler: ()?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    setupReachability()
    if window == nil {
      window = UIWindow(frame: UIScreen.mainScreen().bounds)
    }
    
    setupAWS()
    registerForPush()
    return true
  }
  
  
}

extension AppDelegate { //Networking
  
  func setupReachability() {
    let reachability = Reachability(hostName: serverURL)
    if reachability.isReachable() {
      self.window?.rootViewController = ViewController()
      self.window?.makeKeyAndVisible()
    } else {
      self.window?.rootViewController = UIViewController()
      self.window?.makeKeyAndVisible()
    }
    reachability.reachableBlock = { (reachBlock:Reachability!) in
      //show alert, saying that it's reachable.
    }
    
    reachability.unreachableBlock = { (unreachBlock: Reachability!) in
      //show alert, saying that it's unreachable.
    }
    reachability.startNotifier()
    
    return
      
    AFNetworkReachabilityManager.sharedManager().startMonitoring()
    AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
      switch status {
      case AFNetworkReachabilityStatus.NotReachable: //TODO: handle unreachability
        println("NotReachable")
        assert(false, "Not reachable!")
        break
      case AFNetworkReachabilityStatus.ReachableViaWiFi:
        println("ReachableViaWiFi")
        fallthrough
      case AFNetworkReachabilityStatus.ReachableViaWWAN:
        println("ReachableViaWWAN")
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
        break
      case AFNetworkReachabilityStatus.Unknown:
        println("Unknown")
        break
      }
    }
  }
  
  func setupAWS() {
    let credentialsProvider =
    AWSCognitoCredentialsProvider(
      regionType: CognitoRegionType,
      identityId: nil,
      identityPoolId: CognitoIdentityPoolId,
      logins: nil)
//    let credentialsProvider = AWSCognitoCredentialsProvider(
//      regionType: CognitoRegionType,
//      identityPoolId: CognitoIdentityPoolId)
    let configuration = AWSServiceConfiguration(
      region: DefaultServiceRegionType,
      credentialsProvider: credentialsProvider)
    AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    
    println("credentialsProvider.getIdentityId(): \(credentialsProvider.getIdentityId())")
  }
  
  func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
    println("AppDelegate application handleEventsForBackgroundURLSession")
    if identifier == BackgroundSessionUploadIdentifier {
      self.backgroundUploadSessionCompletionHandler = completionHandler()
    } else if identifier == BackgroundSessionDownloadIdentifier {
      self.backgroundDownloadSessionCompletionHandler = completionHandler()
    }
  }
  
}

extension AppDelegate {
  func registerForPush() { //TODO: ask for user permission
    UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
    UIApplication.sharedApplication().registerForRemoteNotifications()
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let tokenString = tokenStringFrom(data: deviceToken)
    println("tokenString: \(tokenString)")
    let newLocalDevice = Device()
    newLocalDevice.token = tokenString
    deviceManager.registerDevice(device: newLocalDevice)
  }
  
  func tokenStringFrom(#data:NSData) -> String {
    var tokenString = data.description
    tokenString = tokenString.stringByReplacingOccurrencesOfString("<", withString: "", options: nil, range: nil)
    tokenString = tokenString.stringByReplacingOccurrencesOfString(">", withString: "", options: nil, range: nil)
    tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
    return tokenString
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    //
    println("didFailToRegisterForRemoteNotificationsWithError error: \(error)")
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    //
  }
}

extension AppDelegate {


  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

