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
  let reachabilityManager = AFNetworkReachabilityManager()
  let reachability = Reachability(hostName: serverURL)
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    if window == nil {
      window = UIWindow(frame: UIScreen.mainScreen().bounds)
    }
    self.window?.rootViewController = ViewController()
    self.window?.makeKeyAndVisible()
    
    setupReachability()
    setupAWS()
    registerForPush()
    if launchOptions != nil {
//      soulCatcher.catch(launchOptions as [NSObject : AnyObject]!)
    } else {
      printline("launching without options! Attempting to test models here.")
      
    }
    
    return true
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    switch application.applicationState {
    case .Background:
      //called when the push is first received
      completionHandler(.NewData)
      break
    case .Inactive:
      //called when the user interacts with the push
      completionHandler(.NewData)
      break
    case .Active:
      //called when a soul is received while app is open.
      printline("didReceiveRemoteNotification Active!!!")
      soulCatcher.catch(userInfo)
      completionHandler(.NewData)
      break

    }
    //TODO: check for action from userInfo
    
    //soulTester.testIncoming(userInfo)
  }
}

extension AppDelegate { //Networking
  
  func setupReachability() {
//    reachability.reachableBlock = { (reachBlock:Reachability!) in
//      //show alert, saying that it's reachable.
//      NSNotificationCenter.defaultCenter().postNotificationName("nowReachable", object: nil)
//    }
//    reachability.unreachableBlock = { (unreachBlock: Reachability!) in
//      NSNotificationCenter.defaultCenter().postNotificationName("nowUnreachable", object: nil)
//      //show alert, saying that it's unreachable.
//    }
//    reachability.startNotifier()
    
//    
//    if reachabilityManager.reachable {
//      println("reachable")
//    } else {
//      println("unreachable")
//    }
//    reachabilityManager.setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
//      switch status {
//      case .NotReachable:
//        fallthrough
//      case .Unknown:
//        println("Unreachable")
//        break
//      case .ReachableViaWiFi:
//        fallthrough
//      case .ReachableViaWWAN:
//        println("Reachable")
//        break
//      }
//    }
//    reachabilityManager.startMonitoring()
  }
  
  func setupAWS() {
//    let credentialsProvider = AWSCognitoCredentialsProvider(
//      regionType: CognitoRegionType,
//      identityId: nil,
//      identityPoolId: CognitoIdentityPoolId,
//      logins: nil)
    let credentialsProvider = AWSCognitoCredentialsProvider(regionType: CognitoRegionType, identityPoolId: CognitoIdentityPoolId)
    let configuration = AWSServiceConfiguration(
      region: DefaultServiceRegionType,
      credentialsProvider: credentialsProvider)
    AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    
    printline("credentialsProvider.getIdentityId(): \(credentialsProvider.getIdentityId())")
  }
  
  func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
    printline("AppDelegate application handleEventsForBackgroundURLSession")
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
    let localDevice = Device.localDevice
    if let oldToken = Device.localDevice.token { // we were here before
      
    } else {
      localDevice.token = tokenString
      Device.localDevice = localDevice
      deviceManager.register(localDevice)
    }
    
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
    printline("didFailToRegisterForRemoteNotificationsWithError error: \(error)")
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

