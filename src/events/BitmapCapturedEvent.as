package events
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class BitmapCapturedEvent extends Event
	{
		public var bitmapData : BitmapData;
		
		public static const BITMAP_CAPTURED : String = "bitmapCaptured";
		
		public function BitmapCapturedEvent(type:String, bitmapData_:BitmapData, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			bitmapData = bitmapData_;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new BitmapCapturedEvent(type, bitmapData, bubbles, cancelable);
		}
	}
}