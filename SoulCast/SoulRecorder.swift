
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
  let minimumRecordDuration:Float = 1.0
  let maximumRecordDuration:Float = 1.0
  var maximumDurationPassed = false
  var recordingFrames:Int = 0
  var currentRecordingPath:String!
  var timeKeepingBlock: AEBlockChannel!
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
        discardRecording()
      case (.RecordingLongEnough, .Failed):
        assert(false, "Should not be here!!")
      case (.RecordingLongEnough, .Finished):
        saveRecording()
      case (.Failed, .Standby):
        resetRecorder()
      case (.Finished, .Standby):
        resetRecorder()
      case (let x, .Err):
        println("state x.hashValue: \(x.hashValue)")
      default:
        println("oldValue: \(oldValue.hashValue), state: \(state.hashValue)")
        assert(false, "OOPS!!!")
      }
    }
  }
  
  func pleaseStartRecording() {
    if state != .Standby {
      assert(false, "OOPS!! Tried to start recording from an inappropriate state!")
    } else {
      startRecording()
      state = .RecordingStarted
    }
  }
  
  func pleaseStopRecording() {
    if state == .RecordingStarted {
      state = .Failed
    } else if state == .RecordingLongEnough {
      state = .Finished
    }
  }
  
  private func startRecording() {
    var error:NSError?
    let result = audioController.start(&error)
    if let e = error {
      assert(error == nil, "audioController start error: \(error?.localizedDescription)")
    }
    recorder = AERecorder(audioController: audioController)
    currentRecordingPath = outputPath()
    recorder?.beginRecordingToFileAtPath(currentRecordingPath, fileType: AudioFileTypeID(kAudioFileM4AType), error: &error)
    if let e = error {
      println("raRRRWAREEWAR recording unsuccessful! error: \(e)")
      recorder = nil
      return
    }
    audioController.addOutputReceiver(recorder)
    audioController.addInputReceiver(recorder)
    
    //TODO: add a metronome block, subscribe for the minimum record duration.
    timeKeepingBlock = AEBlockChannel(block: { (time: UnsafePointer<AudioTimeStamp>, frames: UInt32, audioList: UnsafeMutablePointer<AudioBufferList>) -> Void in
      for (var i = 0 ; i < Int(frames) ; i++) {
        self.recordingFrames++
        if self.recordingFrames % 44100 == 0 {
          if self.recordingFrames == 44100 {
            //do only if recording state == tooshort
            if self.state == .RecordingStarted {
              self.state = .RecordingLongEnough //do once
            }
            
          }
          if self.recordingFrames == 44100 * 5 {
            if self.state == .RecordingLongEnough {
              self.state = .Finished
            }
            audioController.removeChannels([self.timeKeepingBlock])
          }
        }
      }
    })
    audioController.addChannels([timeKeepingBlock])
    
  }
  
  private func minimumDurationDidPass() {
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
        outputPath = (paths[0] as? String)! + "/Recording" + randomNumberString + ".m4a"
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
    recorder?.finishRecording()
    delegate?.soulDidFailToRecord()
    state = .Standby
  }
  
  private func saveRecording() {
    println("saveRecording")
    recorder?.finishRecording()
    let newSoul = Soul()
    newSoul.localURL = currentRecordingPath
    newSoul.secondsSince1970 = Int(NSDate().timeIntervalSince1970)
    delegate?.soulDidFinishRecording(newSoul)
    state = .Standby
  }
  
  private func resetRecorder() {
    println("resetRecorder")
    audioController.removeOutputReceiver(recorder)
    audioController.removeInputReceiver(recorder)
    recorder = nil
    recordingFrames = 0
  }
  
}
