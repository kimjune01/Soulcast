
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
  let maximumRecordDuration:Int = 3
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
        break
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
        print("state x.hashValue: \(x.hashValue)")
      default:
        print("oldValue: \(oldValue.hashValue), state: \(state.hashValue)")
        assert(false, "OOPS!!!")
      }
    }
  }
  
  func setup() {
    displayLink = CADisplayLink(target: self, selector: "displayLinkFired:")
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    
  }
  
  func displayLinkFired(link:CADisplayLink) {
    if state == .RecordingStarted || state == .RecordingLongEnough { displayCounter += 1 }
    if displayCounter == 60 * minimumRecordDuration {
      print("displayCounter == 60 * minimumRecordDuration")
      if state == .RecordingStarted { minimumDurationDidPass() }
    }
    if displayCounter == 60 * maximumRecordDuration {
      print("displayCounter == 60 * maximumRecordDuration")
      if state == .RecordingLongEnough { pleaseStopRecording() }
      displayCounter = 0
    }
  }
  
  func pleaseStartRecording() {
    print("pleaseStartRecording()")
    if state != .Standby {
      assert(false, "OOPS!! Tried to start recording from an inappropriate state!")
    } else {
      startRecording()
      state = .RecordingStarted
    }
  }
  
  func pleaseStopRecording() {
    print("pleaseStopRecording()")
    if state == .RecordingStarted {
      discardRecording()
    } else if state == .RecordingLongEnough {
      saveRecording()
    }
  }
  
  private func startRecording() {
    print("startRecording()")
    var error:NSError?
    let result = audioController.start(&error)
    if let e = error {
      assert(error == nil, "audioController start error: \(error?.localizedDescription)")
    }
    recorder = AERecorder(audioController: audioController)
    currentRecordingPath = outputPath()
    recorder?.beginRecordingToFileAtPath(currentRecordingPath, fileType: AudioFileTypeID(kAudioFileM4AType), error: &error)
    if let e = error {
      print("raRRRWAREEWAR recording unsuccessful! error: \(e)")
      recorder = nil
      return
    }
    audioController.addOutputReceiver(recorder)
    audioController.addInputReceiver(recorder)
    
  }
  
  private func minimumDurationDidPass() {
    print("minimumDurationDidPass()")
    state = .RecordingLongEnough
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
        print("randomNumberString: \(randomNumberString)")
        outputPath = (paths[0] as? String)! + "/Recording" + randomNumberString + ".m4a"
        let manager = NSFileManager.defaultManager()
        var error:NSError?
        if manager.fileExistsAtPath(outputPath) {
          manager.removeItemAtPath(outputPath, error: &error)
          if let e = error {
            print("outputPath(readOrWrite:FileReadWrite) error: \(e)")
          }
        }
      }
    }
    print("outputPath: \(outputPath)")
    return outputPath
  }
  
  private func discardRecording() {
    print("discardRecording")
    state = .Failed
    recorder?.finishRecording()
    resetRecorder()
    delegate?.soulDidFailToRecord()
  }
  
  private func saveRecording() {
    print("saveRecording")
    state = .Finished
    recorder?.finishRecording()
    resetRecorder()
    let newSoul = Soul()
    newSoul.localURL = currentRecordingPath
    delegate?.soulDidFinishRecording(newSoul)
    
  }
  
  private func resetRecorder() {
    print("resetRecorder")
    state = .Standby
    audioController.removeOutputReceiver(recorder)
    audioController.removeInputReceiver(recorder)
    recorder = nil
    
  }
  
}
