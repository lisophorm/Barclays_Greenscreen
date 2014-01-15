package events
{
	import flash.events.Event;
	
	public class DebugEvent extends Event
	{
		public var socketCode : int;
		
		public static const DEBUG : String = "debug";
		
		public function DebugEvent(type:String, code:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			socketCode = code;
			super(type, bubbles, cancelable);
		}
	}
}