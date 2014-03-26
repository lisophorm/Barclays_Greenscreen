package uk.co.huydinh.app.champion.ui
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class SimpleButton extends MovieClip
	{
		public function SimpleButton()
		{
			super();
			
			stop();
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OVER, handleOver);
			addEventListener(MouseEvent.ROLL_OUT, handleOut);
		}
		
	
		function handleOver(event:MouseEvent):void
		{
			gotoAndStop(3);
		}
		
		function handleOut(event:MouseEvent):void
		{
			gotoAndStop(1);
		}
	}
}