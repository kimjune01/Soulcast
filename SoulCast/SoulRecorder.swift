
import UIKit
import AVFoundation

enum FileReadWrite {
  case Read
  case Write
}

enum RecorderState {
  case Unknown
  case Recording
  case Paused
  case Finished
  case Err
}

protocol SoulRecorderDelegate {
  func soulDidFinishRecording(newSoul: Soul)
  func soulDidFailToRecord()
}

class SoulRecorder: NSObject {
  let minimumRecordDuration:Float = 1.0
  var recordingDuration:Float = 0
  var minimumDurationPassed = false
  var timeKeepingBlock: AEBlockChannel!
  var recorder:AERecorder?
  var delegate:SoulRecorderDelegate?
  //records and spits out the url
  var soulRecorderState: RecorderState = .Unknown{
    didSet{
      switch (oldValue, soulRecorderState){
      case (.Unknown, .Recording):
        startRecording()
      case (.Recording, .Paused):
        pauseRecording()
      case (.Paused, .Recording):
        resumeRecording()
      case (.Recording, .Finished):
        saveRecording()
      case (.Finished, .Unknown):
        resetRecorder()
      case (let x, .Err):
        println("soulRecorderState x.hashValue: \(x.hashValue)")
      default:
        assert(false, "OOPS!!!")
      }
    }
  }
  
  
  func requestRecording() {
    if soulRecorderState == .Recording {return}
    soulRecorderState = .Recording
  }
  
  func startRecording() {
    var error:NSError?
    recorder = AERecorder(audioController: audioController)
    recorder?.beginRecordingToFileAtPath( outputPath(.Write), fileType: AudioFileTypeID(kAudioFileAIFFType), error: &error)
    if let e = error {
      println("raRRRWAREEWAR recording unsuccessful! error: \(e)")
      recorder = nil
      return
    }
    changeUIForRecording()
    audioController.addOutputReceiver(recorder)
    audioController.addInputReceiver(recorder)
    
    //TODO: add a metronome block, subscribe for the minimum record duration.
    timeKeepingBlock = AEBlockChannel(block: { (time: UnsafePointer<AudioTimeStamp>, frames: UInt32, audioList: UnsafeMutablePointer<AudioBufferList>) -> Void in
      println("time: \(time), frames: \(frames), audioList: \(audioList)")
      
    })
    
    let result = audioController.start(&error)
    if result {
      audioController.addChannels([timeKeepingBlock])
    } else {
      println("audioController start error: \(error?.localizedDescription)")
    }
  
    
    
  }
  
  func pauseRecording() {
    //TODO:
  }
  
  func resumeRecording() {
    //TODO:
  }
  
  func changeUIForRecording() {
    
  }
  
  func outputPath(readOrWrite:FileReadWrite) -> String {
    var outputPath:String!
    
    if let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) {
      if paths.count > 0 {
        outputPath = (paths[0] as? String)! + "/Recording.aiff"
        if readOrWrite == .Write {
          let manager = NSFileManager.defaultManager()
          var error:NSError?
          manager.removeItemAtPath(outputPath, error: &error)
          if let e = error {
            println("outputPath(readOrWrite:FileReadWrite) error: \(e)")
          }
        }
      }
    }
    return outputPath
  }
  
  func saveRecording() {
    //move to temporary directory, signal
    //TODO: compress into AAC
    //http://atastypixel.com/blog/easy-aac-compressed-audio-conversion-on-ios/
    //https://github.com/michaeltyson/TPAACAudioConverter
    delegate?.soulDidFinishRecording(Soul())
  }
  
  func resetRecorder() {
    //TODO
  }
  
}
