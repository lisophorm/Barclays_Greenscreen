package com.alfo.utils
{
	public class ChromaSettings
	{
		public var  Hue:Number;
		public var  Tolerance:Number;
		public var  Saturation:Number;
		public var  MinValue:Number;
		public var  MaxValue:Number;
		
		public function ChromaSettings(Hue:Number = 120,Tolerance:Number = 45,Saturation:Number = 0.2,MinValue:Number = 0.35,MaxValue:Number = 0.95)
		{
			this.Hue = Hue;
			this.Tolerance = Tolerance;
			this.Saturation = Saturation;
			this.MinValue = MinValue;
			this.MaxValue = MaxValue;
		}
	}
}