
class SwiftJK {

}

func doOnce (taskName:String, task:() -> ()) -> (Bool) {
  if NSUserDefaults.standardUserDefaults().valueForKey("doOnce-" + taskName) == nil {
    task()
    NSUserDefaults.standardUserDefaults().setValue(true, forKey: "doOnce-" + taskName)
    return true
  } else {
    return false
  }
}