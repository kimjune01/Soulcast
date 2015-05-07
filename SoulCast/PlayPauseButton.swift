

import UIKit

enum PlayingOrPaused {
  case Playing
  case Pausing
  case Paused
}

class PlayPauseButton: UIButton {

  var buttonState:PlayingOrPaused = .Paused {
    didSet(oldValue) {
      println("oldValue: \(oldValue.hashValue), newButtonState: \(buttonState.hashValue)")
    }
  }
  
  func play() {
    buttonState = .Playing
    self.backgroundColor = UIColor.greenColor()
  }
  
  func pause() {
    buttonState = .Pausing
    self.backgroundColor = UIColor.redColor()
  }

}
