package events
{
	import flash.events.Event;
	
	public class RegistrationEvent extends Event
	{
		
		public static var SCAN_READY:String 		= "SCAN_READY";
		public static var SCAN_STEP_1:String	 	= "SCAN_STEP_1";
		public static var SCAN_STEP_2:String	 	= "SCAN_STEP_2";
		public static var SCAN_STEP_3:String 		= "SCAN_STEP_3";
		public static var SCAN_COMPLETED:String 	= "SCAN_COMPLETED";
		public static var SCAN_AGAIN:String			= "SCAN_AGAIN";
		public static var SCAN_RESTART:String 		= "SCAN_RESTART";
		public static var SCAN_CANCELLED:String 	= "SCAN_CANCELLED";
		
		public static var USER_FOUND:String 			= "USER_FOUND";
		public static var USER_REGISTERED:String 			= "USER_REGISTERED";
		public static var USER_ALREADY_REGISTERED:String 	= "USER_ALREADY_REGISTERED";
		public static var USER_NOT_FOUND:String 			= "USER_NOT_FOUND";
		
		public static var ERROR:String = "ERROR";
		
		public var userid:int=-1;
		public var message:String="";
		public function RegistrationEvent(type:String, userid:int=-1,msg:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			trace(msg);
			this.userid = userid;
			this.message = msg;
			super(type, bubbles, cancelable);
		}
	}
}