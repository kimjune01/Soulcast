//
//  SoulCaster.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

enum UploaderState {
  case Unknown
  case Uploading
  case Failed
  case Finished
}

protocol SoulCasterDelegate {
  func soulDidStartUploading()
  func soulIsUploading(progress:Float)
  func soulDidFinishUploading()
  func soulDidFailToUpload()
  func soulDidReachServer()
}

var singleSoulCaster:SoulCaster = SoulCaster()

class SoulCaster: NSObject {
  
  var session: NSURLSession?
  var uploadTask: NSURLSessionUploadTask?
  var uploadFileURL: NSURL?
  var uploadProgress: Float = 0
  let fileContentTypeStr = "audio/mpeg"
  
  var outgoingSoul:Soul?
  var delegate:SoulCasterDelegate?
  
  var soulCasterState:UploaderState = .Unknown {
    didSet {
      switch (oldValue, soulCasterState) {
      case (.Unknown, .Uploading):
        break
        
      case (.Uploading, .Finished):
        break
        //notifyDelegate()
      case (.Finished, .Unknown):
        break
        //reset()
      case (let x, .Failed):
        println("soulCasterState x.hashValue: \(x.hashValue)")
      default:
        assert(false, "OOPS!!!")
      }
    }
  }
  
  override init() {
    super.init()
    setup()
  }
  
  func setup() {
    var token: dispatch_once_t = 0
    dispatch_once(&token) {
      let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(BackgroundSessionUploadIdentifier)
      self.session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    uploadProgress = 0
  }
  
  func upload(localSoul:Soul) {
    self.outgoingSoul = localSoul
    assert(localSoul.localURL != nil, "There's nothing to upload!!!")
    self.uploadFileURL = NSURL(fileURLWithPath: localSoul.localURL!)
    println("upload localSoul: \(localSoul) self.uploadFileURL: \(self.uploadFileURL)")
    assert(localSoul.epoch != nil, "There's no key assigned to the soul!!!")
    if (self.uploadTask != nil) {
      return;
    }
    //
    let uploadKey = localSoul.s3Key! + ".mp3"
    let presignedURLRequest = getPreSignedURLRequest(uploadKey)
    AWSS3PreSignedURLBuilder.defaultS3PreSignedURLBuilder().getPreSignedURL(presignedURLRequest) .continueWithBlock { (task:BFTask!) -> (AnyObject!) in
      
      if (task.error != nil) {
        NSLog("Error: %@", task.error)
      } else {
        
        let presignedURL = task.result as NSURL!
        if (presignedURL != nil) {
          var request = NSMutableURLRequest(URL: presignedURL)
          request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
          request.HTTPMethod = "PUT"
          
          //contentType in the URLRequest must be the same as the one in getPresignedURLRequest
          request.setValue(self.fileContentTypeStr, forHTTPHeaderField: "Content-Type")
          
          self.uploadTask = self.session?.uploadTaskWithRequest(request, fromFile: self.uploadFileURL!)
          self.uploadTask?.resume()
          self.delegate?.soulDidStartUploading()
        }
      }
      return nil;
      
    }
    
    
  }
  
  func getPreSignedURLRequest(keyName: String) -> AWSS3GetPreSignedURLRequest {
    let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
    getPreSignedURLRequest.bucket = S3BucketName
    getPreSignedURLRequest.key = keyName
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethod.PUT
    getPreSignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600)
    getPreSignedURLRequest.contentType = fileContentTypeStr
    
    return getPreSignedURLRequest
  }
  
  func notifyDelegate() {
    
  }
  
  func reset() {
    
  }
  
}

extension SoulCaster: NSURLSessionDataDelegate {
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    println("Soul upload progress: \(progress)")
    self.uploadProgress = progress
    if let tempDelegate = self.delegate? {
      dispatch_async(dispatch_get_main_queue()) {
        tempDelegate.soulIsUploading(progress)
      }
    }
    
  }
}

extension SoulCaster: NSURLSessionTaskDelegate {
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    //finished
    if let tempDelegate = self.delegate? {
      if (error == nil) {
        dispatch_async(dispatch_get_main_queue()) {
          tempDelegate.soulDidFinishUploading()
        }
        //castSoulToServer(outgoingSoul!)
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          tempDelegate.soulDidFailToUpload()
        }
      }
    }
    
    self.uploadTask = nil
    
  }
}

extension SoulCaster: NSURLSessionDelegate {
  func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    if ((appDelegate.backgroundUploadSessionCompletionHandler) != nil) {
      let completionHandler:() = appDelegate.backgroundUploadSessionCompletionHandler!;
      appDelegate.backgroundUploadSessionCompletionHandler = nil
      completionHandler
    }
    
    println("Completion Handler has been invoked, background upload task has finished.")
  }
}

extension SoulCaster {
  func castSoulToServer(outgoingSoul:Soul) {
    let manager = AFHTTPRequestOperationManager()
    var params = outgoingSoul.toParams(type: "outgoing")
    
    manager.requestSerializer = AFJSONRequestSerializer(writingOptions: NSJSONWritingOptions.PrettyPrinted)
    manager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.MutableContainers)
    
    manager.POST(serverURL + newSoulSuffix, parameters: params, success: { (operation: AFHTTPRequestOperation!, returnObject: AnyObject!) -> Void in
      self.delegate?.soulDidReachServer()
      println("castSoulToServer operation: \(operation) returnObject: \(returnObject)")
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        println("castSoulToServer operation: \(operation) error: \(error)")
    }
    

    
  }
  
  /*
  Prefix Verb         URI Pattern                   Controller#Action
  api_souls GET       /api/souls(.:format)          api/souls#index
  POST                /api/souls(.:format)          api/souls#create
  new_api_soul GET    /api/souls/new(.:format)      api/souls#new
  edit_api_soul GET   /api/souls/:id/edit(.:format) api/souls#edit
  api_soul GET        /api/souls/:id(.:format)      api/souls#show
  PATCH               /api/souls/:id(.:format)      api/souls#update
  PUT                 /api/souls/:id(.:format)      api/souls#update
  DELETE              /api/souls/:id(.:format)      api/souls#destroy
*/
  
}
