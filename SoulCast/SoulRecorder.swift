
import UIKit
import AVFoundation

enum FileReadWrite {
  case Read
  case Write
}

enum RecorderState {
  case Standby // 0
  case RecordingStarted
  case RecordingLongEnough // 2
  case Paused
  case Failed // 4
  case Finished // 5
  case Unknown // 6
  case Err
}

protocol SoulRecorderDelegate {
  func soulDidStartRecording()
  func soulDidFinishRecording(newSoul: Soul)
  func soulDidFailToRecord()
  func soulDidReachMinimumDuration()
}

class SoulRecorder: NSObject {
  let minimumRecordDuration:Int = 1
  let maximumRecordDuration:Int = 5
  var maximumDurationPassed = false
  var currentRecordingPath:String!
  var displayLink:CADisplayLink!
  var displayCounter:Int = 0
  var recorder:AERecorder?
  var delegate:SoulRecorderDelegate?
  //records and spits out the url
  var state: RecorderState = .Standby{
    didSet{
      switch (oldValue, state){
      case (.Standby, .RecordingStarted):
        break
      case (.RecordingStarted, .RecordingLongEnough):
        minimumDurationDidPass()
      case (.RecordingStarted, .Failed):
        break
      case (.RecordingLongEnough, .Failed):
        assert(false, "Should not be here!!")
      case (.RecordingLongEnough, .Finished):
        break
      case (.Failed, .Standby):
        break
      case (.Finished, .Standby):
        break
      case (let x, .Err):
        println("state x.hashValue: \(x.hashValue)")
      default:
        println("oldValue: \(oldValue.hashValue), state: \(state.hashValue)")
        assert(false, "OOPS!!!")
      }
    }
  }
  
  func setup() {
    displayLink = CADisplayLink(target: self, selector: "displayLinkFired:")
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    
  }
  
  func displayLinkFired(link:CADisplayLink) {
    if state == .RecordingStarted || state == .RecordingLongEnough { displayCounter++ }
    if displayCounter == 60 * minimumRecordDuration {
      println("displayCounter == 60 * minimumRecordDuration")
      if state == .RecordingStarted { state = .RecordingLongEnough }
    }
    if displayCounter == 60 * maximumRecordDuration {
      println("displayCounter == 60 * maximumRecordDuration")
      if state == .RecordingLongEnough { pleaseStopRecording() }
      displayCounter = 0
    }
  }
  
  func pleaseStartRecording() {
    println("pleaseStartRecording()")
    if state != .Standby {
      assert(false, "OOPS!! Tried to start recording from an inappropriate state!")
    } else {
      startRecording()
      state = .RecordingStarted
    }
  }
  
  func pleaseStopRecording() {
    println("pleaseStopRecording()")
    if state == .RecordingStarted {
      discardRecording()
    } else if state == .RecordingLongEnough {
      saveRecording()
    }
  }
  
  private func startRecording() {
    println("startRecording()")
    var error:NSError?
    let result = audioController.start(&error)
    if let e = error {
      assert(error == nil, "audioController start error: \(error?.localizedDescription)")
    }
    recorder = AERecorder(audioController: audioController)
    currentRecordingPath = outputPath()
    recorder?.beginRecordingToFileAtPath(currentRecordingPath, fileType: AudioFileTypeID(kAudioFileAIFFType), error: &error)
    if let e = error {
      println("raRRRWAREEWAR recording unsuccessful! error: \(e)")
      recorder = nil
      return
    }
    audioController.addOutputReceiver(recorder)
    audioController.addInputReceiver(recorder)
    
  }
  
  private func minimumDurationDidPass() {
    println("minimumDurationDidPass()")
    delegate?.soulDidReachMinimumDuration()
  }
  
  private func pauseRecording() {
    //TODO:
  }
  
  private func resumeRecording() {
    //TODO:
  }
  
  func outputPath() -> String {
    var outputPath:String!
    
    if let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) {
      if paths.count > 0 {
        let randomNumberString = String(NSDate.timeIntervalSinceReferenceDate().description)
        println("randomNumberString: \(randomNumberString)")
        outputPath = (paths[0] as? String)! + "/Recording" + randomNumberString + ".aiff"
        let manager = NSFileManager.defaultManager()
        var error:NSError?
        if manager.fileExistsAtPath(outputPath) {
          manager.removeItemAtPath(outputPath, error: &error)
          if let e = error {
            println("outputPath(readOrWrite:FileReadWrite) error: \(e)")
          }
        }
      }
    }
    return outputPath
  }
  
  private func discardRecording() {
    println("discardRecording")
    state = .Failed
    resetRecorder()
    recorder?.finishRecording()
    delegate?.soulDidFailToRecord()
  }
  
  private func saveRecording() {
    println("saveRecording")
    state = .Finished
    recorder?.finishRecording()
    resetRecorder()
    let newSoul = Soul()
    newSoul.localURL = currentRecordingPath
    newSoul.secondsSince1970 = Int(NSDate().timeIntervalSince1970)
    delegate?.soulDidFinishRecording(newSoul)
    
  }
  
  private func resetRecorder() {
    println("resetRecorder")
    state = .Standby
    audioController.removeOutputReceiver(recorder)
    audioController.removeInputReceiver(recorder)
    recorder = nil
    
  }
  
}
