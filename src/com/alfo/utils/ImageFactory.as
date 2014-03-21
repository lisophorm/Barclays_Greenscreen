package com.alfo.utils
{
	import com.alfo.chroma.Chromagic;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.components.Image;

	public class ImageFactory
	{
		
		public var settings:GreenScreenPrefs;
		
		private var height:Number;
		private var width:Number;
		private var scale:Number;
		
		private var chroma:Chromagic=new Chromagic();
		
		public static var background:BitmapData;
		public static var photo:BitmapData;
		public static var chromed:BitmapData;
		
		private var  _Hue:Number;
		private var  _Tolerance:Number;
		private var  _Saturation:Number;
		private var  _MinValue:Number;
		private var  _MaxValue:Number;
		
		private var _trophy:Rectangle;
		private var _crop:Rectangle;
		
		public function ImageFactory(width:Number=800,height:Number=800,scale:Number=1)
		{
			this.width=width;
			this.height=height;
			this.scale=scale;
		}

		public function get crop():Rectangle
		{
			return _crop;
		}

		public function set crop(value:Rectangle):void
		{
			_crop = value;
		}

		public function get trophy():Rectangle
		{
			return _trophy;
		}

		public function set trophy(value:Rectangle):void
		{
			_trophy = value;
		}

		public function get MaxValue():Number
		{
			return _MaxValue;
		}

		public function set MaxValue(value:Number):void
		{
			chroma.MaxValue=value;
			_MaxValue = value;
		}

		public function get MinValue():Number
		{
			return _MinValue;
		}

		public function set MinValue(value:Number):void
		{
			chroma.MinValue=value;
			_MinValue = value;
		}

		public function get Saturation():Number
		{
			return _Saturation;
		}

		public function set Saturation(value:Number):void
		{
			chroma.Saturation=value;
			_Saturation = value;
		}

		public function get Tolerance():Number
		{
			return _Tolerance;
		}

		public function set Tolerance(value:Number):void
		{
			chroma.Tolerance=value;
			_Tolerance = value;
		}

		public function get Hue():Number
		{
			
			return _Hue;
		}

		public function set Hue(value:Number):void
		{
			chroma.Hue=value;
			_Hue = value;
		}

		public function processImage(source:BitmapData,trophy:BitmapData,backGroundImage:spark.components.Image):BitmapData {
			var cupMatrix:Matrix=new Matrix();
			cupMatrix.scale(_trophy.width*scale,_trophy.height*scale);
			cupMatrix.translate(_trophy.x*scale,_trophy.y*scale);
			background=new BitmapData(this.width,this.height,true);
			photo=source;
			chromed=chroma.key(photo);
			background.draw(backGroundImage.bitmapData);
			background.copyPixels(chromed,new Rectangle(_crop.x*scale,_crop.y*scale,_crop.width*scale,_crop.height*scale),new Point(_crop.x*scale,_crop.y*scale),null,null,true);
			background.draw(trophy,cupMatrix);
			return background;
		}
		
		public function colorPicker(x:Number,y:Number,image:BitmapData):Vector.<Number> {
			
			var rgb : Vector.<Number> = new <Number>[0, 0, 0, 0];
			var currenPixel:uint=image.getPixel32(x/scale,y/scale);
			
			rgb[2] = (currenPixel & 0xFF) / 255.0;
			rgb[1] = (currenPixel >> 8 & 0xFF) / 255.0;
			rgb[0] = (currenPixel >> 16 & 0xFF) / 255.0;
			rgb[3] = (currenPixel >> 24 & 0xFF) / 255.0; 
			
			var hsv:Vector.<Number>=chroma.RGB_to_HSV(rgb);
			return hsv;
		}
									
	}
}