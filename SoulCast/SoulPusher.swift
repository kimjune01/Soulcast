//
//  SoulPusher.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-04-04.
//  Copyright (c) 2015 June. All rights reserved.
//

let soulPusher = SoulPusher()
///Pushes a soul to a device
class SoulPusher: NSObject {

  func push(#soul:Soul, toDevice:Device) -> Bool {
    
    AWSSNS.defaultSNS().publish(publishInput(soul, device: toDevice))
    return false
  }
  
  
  func publishInput(soul:Soul, device:Device) -> AWSSNSPublishInput {
    let input = AWSSNSPublishInput()
    input.message = message(soul)
    input.messageStructure = "json"
    input.targetArn = device.arn
    return input
  }
  
  func message(soul:Soul) -> String {
    let containerParams = NSMutableDictionary()
    let wrapperParams = NSMutableDictionary()
    wrapperParams["aps"] = soulParams(soul)
    containerParams[pushProtocol] = toJSON(wrapperParams)
    return toJSON(containerParams)
  }
  
  func soulParams(soul:Soul) -> NSDictionary {
    let soulParams = NSMutableDictionary(dictionary: soul.toParams(type: "direct"))
    soulParams["alert"] = "A soul has spoken directly at you"
    soulParams["sound"] = "default"
    return soulParams
  }
  
  func toJSON(params:NSDictionary) -> String {
    var error:NSError?
    let jsonData = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
    assert(error == nil, "JSON Serialization error!")
    let jsonString = jsonData!.description
    println(jsonString)
    return jsonString
    
  }
  /*
  def push_message (soul)
  {Global.AWS.push_protocol => {:aps => soul_hash(soul)}.to_json}
  end
  def soul_hash (soul)
  {:soul => soul.attributes, :alert => "A soul breezes by you", :sound => 'default'}
  end
  */

  //TODO: a function that takes in a device, sends a silent push, and determines whether it can catch, returns Bool
  
  func localToken() -> String {
    return NSUserDefaults.standardUserDefaults().valueForKey("token") as String
  }
}
