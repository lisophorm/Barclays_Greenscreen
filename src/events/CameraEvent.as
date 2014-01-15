package events
{
	import flash.events.Event;
	
	public class CameraEvent extends Event
	{
		
		public static var COMPLETE:String = "COMPLETE";
		public static var ERROR:String = "ERROR";
		public static var PROGRESS:String = "PROGRESS";
		
		public var data:Object;
		
		public function CameraEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;	
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new CameraEvent(type, data, bubbles, cancelable);
		}
	}
}