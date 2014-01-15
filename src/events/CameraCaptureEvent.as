package events
{
	import flash.events.Event;
	
	public class CameraCaptureEvent extends Event
	{
		public static const NEXT_SCREEN : String = "nextScreen";
		public static const TICK : String = "tick";
		public static const RETAKE : String = "retake";
		public static const CAMERA_COMPLETE : String = "cameraComplete";
		
		public var countdownValue : int;
		
		public function CameraCaptureEvent(type:String, countdownValue_:int = 0, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			countdownValue = countdownValue_;
		}
		
		override public function clone():Event
		{
			return new CameraCaptureEvent(type, countdownValue, bubbles, cancelable);
		}
	}
}