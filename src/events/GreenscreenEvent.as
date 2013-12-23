package events
{
	import flash.events.Event;
	
	public class GreenscreenEvent extends Event
	{
		
		public static var ERROR:String 				= "ERROR";
		public static var PHOTO_READY:String	 	= "PHOTO_READY";
		public static var WAIT:String	 			= "WAIT";
		
		
		public var data:Object = null
		public function GreenscreenEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}