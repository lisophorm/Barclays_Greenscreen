package events
{
	import flash.events.Event;
	
	public class CameraSelectionEvent extends Event
	{
		public var cameraID : int;
		
		public static var CAMERA_SELECTED : String = "camera_selected";
		
		public function CameraSelectionEvent(type:String, cameraID_:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			cameraID = cameraID_;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new CameraSelectionEvent(type, cameraID, bubbles, cancelable);
		}
	}
}