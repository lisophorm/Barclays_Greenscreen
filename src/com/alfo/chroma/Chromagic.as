package com.alfo.chroma
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
//	import avm2.intrinsics.memory.lf64;
//	import avm2.intrinsics.memory.sf64;
	
	
	public class Chromagic extends EventDispatcher
	{
		public var  Hue:Number;
		public var  Tolerance:Number;
		public var  Saturation:Number;
		public var  MinValue:Number;
		public var  MaxValue:Number;
		
		public static var colorInHSV:Vector.<Number> = new <Number>[0, 0, 0, 0];
		public static var hsvinRGB:Vector.<Number> = new <Number>[0, 0, 0, 0];
		
		public static var blancVec:Vector.<Number> = new <Number>[0, 0, 0, 0];

		private var dataBytes:Vector.<uint>;
		public var destDataBytes:ByteArray=new ByteArray();
		
		public var picPos:int = 0;
		
		public function Chromagic()
		{
			this.Hue = 120;
			this.Tolerance = 45;
			this.Saturation = 0.2;
			this.MinValue = 0.35;
			this.MaxValue = 0.95;
		}
		
		public function chroma(width:Number,height:Number,rgba:BitmapData):void {
			//process(width, height, rgba);	
		}
		public function HSV_to_RGB(hsv : Vector.<Number> ):Vector.<Number>
		{
			Chromagic.colorInHSV=blancVec;
			//var color : Vector.<Number> = new <Number>[0, 0, 0, 0];
			//float color[4] = {0.0f, 0.0f, 0.0f, 0.0f};
			var f:Number,p:Number,q:Number,t:Number;

			var r:Number=0,g:Number=0,b:Number=0;
			var i:uint;
			
			if(hsv[1] == 0)
			{
				if(hsv[2] != 0)
				{
					Chromagic.colorInHSV[0] = Chromagic.colorInHSV[1] = Chromagic.colorInHSV[2] = Chromagic.colorInHSV[3] = hsv[2];
				}
			}
			else
			{
				hsv[0] *= 360;

				
				if (hsv[0] == 360.0)
				{
					hsv[0]=0;
				}
				
				hsv[0] /= 60;
				
				// original
				
				i=Math.floor(hsv[0]); //(float)((int)h);
				
				f =	hsv[0] - i;
				
				p =	hsv[2] *	(1 - hsv[1]); 
				q =	hsv[2] *	(1 - (hsv[1] *	f));
				t =	hsv[2] *	(1 - (hsv[1] *	(1 -f)));
				if(i < 0.01)
				{
					Chromagic.colorInHSV[0] =	hsv[2];
					Chromagic.colorInHSV[1] =	t;
					Chromagic.colorInHSV[2] =	p;
				}
				else if(i < 1.01)
				{
					Chromagic.colorInHSV[0] =	q;
					Chromagic.colorInHSV[1] =	hsv[2];
					Chromagic.colorInHSV[2] =	p;
				}
				else if(i < 2.01)
				{
					Chromagic.colorInHSV[0] =	p;
					Chromagic.colorInHSV[1] =	hsv[2];
					Chromagic.colorInHSV[2] =	t;
				}
				else if(i < 3.01)
				{
					Chromagic.colorInHSV[0] =	p;
					Chromagic.colorInHSV[1] =	q;
					Chromagic.colorInHSV[2] =	hsv[2];
				}
				else if(i < 4.01)
				{
					Chromagic.colorInHSV[0] =	t;
					Chromagic.colorInHSV[1] =	p;
					Chromagic.colorInHSV[2] =	hsv[2];
				}
				else if(i < 5.01)
				{
					Chromagic.colorInHSV[0] =	hsv[2];
					Chromagic.colorInHSV[1] =	p;
					Chromagic.colorInHSV[2] =	q;
				}
				
				
			} 
			Chromagic.colorInHSV[3] = hsv[3];
			
			//rgb[0] = Chromagic.colorInHSV[0];
			//rgb[1] = Chromagic.colorInHSV[1];
			//rgb[2] = Chromagic.colorInHSV[2];
			//rgb[3] = Chromagic.colorInHSV[3];
			
			return Chromagic.colorInHSV;
		} 
		
		public function RGB_to_HSV(color:Vector.<Number>):Vector.<Number>
		{
			//var hsv : Vector.<Number> = new <Number>[0, 0, 0, 0];
			var delta:Number;
			var colorMax:Number, colorMin:Number;
			var s:Number = 0;
			var v:Number = 0;

			
			//trace("r:"+r.toString()+"g:"+g.toString()+"b:"+b.toString());
			
			colorMax = Math.max(color[0],color[1]);
			colorMax = Math.max(colorMax,color[2]);
			colorMin = Math.min(color[0],color[1]);
			colorMin = Math.min(colorMin,color[2]);
			
			//hsv values
			Chromagic.hsvinRGB[2] = colorMax;
			
			if(colorMax != 0)
			{
				Chromagic.hsvinRGB[1] = (colorMax - colorMin) / colorMax;
			}
			if(Chromagic.hsvinRGB[1] != 0) // if not achromatic
			{
				//trace("not achromatic");
				delta = colorMax - colorMin;
				if (color[0] == colorMax)
				{
					Chromagic.hsvinRGB[0] = (color[1]-color[2])/delta;
				}
				else if (color[1] == colorMax)
				{
					Chromagic.hsvinRGB[0] = 2.0 + (color[2]-color[0]) / delta;
				}
				else // b is max
				{
					Chromagic.hsvinRGB[0] = 4.0 + (color[0]-color[1])/delta;
				}
				Chromagic.hsvinRGB[0] *= 60;
				
				if( Chromagic.hsvinRGB[0] < 0)
				{
					Chromagic.hsvinRGB[0] +=360;
				}
				
			} 
			
			Chromagic.hsvinRGB[0] = Chromagic.hsvinRGB[0] / 360.0; // moving h to be between 0 and 1.


			Chromagic.hsvinRGB[3] = color[3];
			//trace("h:"+hsv[0].toString()+"s:"+hsv[1].toString()+"v:"+hsv[2].toString()+"a:"+hsv[3].toString());
			//var color:uint = a << 24 | r << 16 | g << 8 | b;
			return Chromagic.hsvinRGB;
		}
		
		
		
		
		public function key(m_video_input:BitmapData,useSpill:Boolean=false):BitmapData
		{
			var bits:String;
			var currentPixel:uint;
			var imgHeight:uint=m_video_input.height;
			var imgWidth:uint=m_video_input.width;
			var keyedBmp:BitmapData=new BitmapData(m_video_input.width,m_video_input.height,true,0xAABBCCDD);
			//destDataBytes
			destDataBytes.endian=Endian.LITTLE_ENDIAN;
			destDataBytes=m_video_input.getPixels(new Rectangle(0,0,m_video_input.width,m_video_input.height));
			//dataBytes=m_video_input.getPixels(new Rectangle(0,0,m_video_input.width,m_video_input.height));
			dataBytes=m_video_input.getVector(new Rectangle(0,0,m_video_input.width,m_video_input.height));
			//dataBytes.position=0;
			//destDataBytes.position=0;
			
			var rgb : Vector.<Number> = new <Number>[0, 0, 0, 0];
			var hsv : Vector.<Number> = new <Number>[0, 0, 0, 0];
			
			var numArray : Vector.<Number> = new <Number>[0, 0, 0, 0];
			
			var num1:Number = this.Hue - this.Tolerance;
			var num2:Number = this.Hue + this.Tolerance;
			var num3:Number = this.Tolerance / 360;
			var num4:Number = num1 / 360;
			var num5:Number = num2 / 360;
			var sat:Number = this.Saturation;
			

			trace("key start");
			var startTime:uint = getTimer();
			var lengo:uint=destDataBytes.length/4;
			var rgbString:String;
			destDataBytes.position=0;
			var currenPixel:uint;
			for(picPos = 0; picPos <lengo; picPos++)
			{
				currenPixel=destDataBytes.readUnsignedInt();
//				trace("byte in hex: "+currenPixel.toString(16)+" position:"+picPos+" length:"+lengo);
				rgb[2] = (currenPixel & 0xFF) / 255.0;
				rgb[1] = (currenPixel >> 8 & 0xFF) / 255.0;
				rgb[0] = (currenPixel >> 16 & 0xFF) / 255.0;
				rgb[3] = (currenPixel >> 24 & 0xFF) / 255.0; 
				

				
				/*rgbString=rgb[0].toString(16);
				rgbString+=rgb[1].toString(16);
				rgbString+=rgb[2].toString(16);
				rgbString+=rgb[3].toString(16);*/
				
				
				
				
				hsv=RGB_to_HSV(rgb);
				
				if(hsv[0] > num4 && hsv[0] < num5)
				{
					if ( hsv[1] >=  sat)
					{
						if ( hsv[2] >=  this.MinValue &&  hsv[2] <=  this.MaxValue)
						{
							hsv[3] = 0.0;
							hsv[1] = 0.0;
							rgb=HSV_to_RGB(hsv);
						}
						else if ( hsv[2] < this.MinValue)
						{
							hsv[3] = Math.min(1, ( this.MinValue + 1.0 -  hsv[2] /  this.MinValue));
							hsv[1] = 0.0;
							hsv[2] = 0.0;
							rgb=HSV_to_RGB(hsv);
						}
						else if ( hsv[2] > this.MaxValue)
						{
							hsv[3] = Math.min(1,((hsv[2] -  this.MaxValue) / (1.0 - this.MaxValue)));
							hsv[1] = 0.0;
							hsv[2] = 1;
							rgb=HSV_to_RGB(hsv);
						}
					} else
					{
						hsv[3] = 1;
						hsv[1] = 0.0;
						rgb=HSV_to_RGB(hsv);
					}
					dataBytes[picPos] = (rgb[3] * 255.0) << 24 | (rgb[0] * 255.0) << 16 | (rgb[1] * 255.0) << 8 | (rgb[2] * 255.0);
				}
				

				
			}
			//try {
			//destDataBytes.position=0;
			//keyedBmp.setPixels(new Rectangle(0,0,m_video_input.width,m_video_input.height),destDataBytes);
			//} catch (e:Error) {
			//	trace("error in setpixels");
			//}
			
			var endTime:uint = getTimer();
			trace("key done in : " + (endTime-startTime)/1000);

			keyedBmp.setVector(new Rectangle(0,0,m_video_input.width,m_video_input.height),dataBytes);
			return keyedBmp;
		}
		
		public function argb2vec(theNumber:uint):Vector.<Number> 
		{
			var theValue : Vector.<Number> = new <Number>[0, 0, 0, 0];
			// alpha
			theValue[3]=theNumber >> 24 & 0xFF;
			//red
			theValue[0]=theNumber >> 16 & 0xFF;
			//green
			theValue[1]=theNumber >> 8 & 0xFF;
			//blue
			theValue[2]=theNumber & 0xFF;
			
			
			return theValue;
		}
		
		
		
		function extractRed(c:uint):uint {
			return (( c >> 16 ) & 0xFF);
		}
		
		function extractGreen(c:uint):uint {
			return ( (c >> 8) & 0xFF );
		}
		
		function extractBlue(c:uint):uint {
			return ( c & 0xFF );
		}
	}
}