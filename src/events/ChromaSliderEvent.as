package events
{
	import flash.events.Event;
	
	public class ChromaSliderEvent extends Event
	{
		
		public static var CHANGE:String = "CHANGE";

		
		public var  Hue:Number;
		public var  Tolerance:Number;
		public var  Saturation:Number;
		public var  MinValue:Number;
		public var  MaxValue:Number;
		
		public function ChromaSliderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		

	}
}