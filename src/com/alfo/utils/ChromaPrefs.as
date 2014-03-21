package com.alfo.utils
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
		
	public class ChromaPrefs extends Sprite
	{
		private static var _instance:ChromaPrefs=null;
		//public var urn:String;
		private var prefsFile:File;
		private var stream:FileStream;
		
		[Bindable]
		public var prefsXML:XML;
		
		public var  Hue:Number;
		public var  Tolerance:Number;
		public var  Saturation:Number;
		public var  MinValue:Number;
		public var  MaxValue:Number;
		
		public var cupX:Number;
		public var cupY:Number;
		public var cupWidth:Number;
		public var cupHeight:Number;
		
		public var cropX:Number;
		public var cropY:Number;
		public var cropWidth:Number;
		public var cropHeight:Number;
		
		public var colorPickerX:Number;
		public var colorPickerY:Number;
		public var autoColor:Number=0;

		
		
		public function ChromaPrefs()
		{
			trace("inizializza userObject");
		}
		
		public static function getInstance():ChromaPrefs {
			if(_instance==null) {
				trace("******* singleton first instance");
				_instance=new ChromaPrefs();
				_instance.init();
			} else {
				trace("**************old instance");
				trace(_instance.prefsXML.toXMLString());

			}
			return _instance;
		}
		
		public function init():void {
			prefsFile = File.applicationStorageDirectory;
			prefsFile = prefsFile.resolvePath("assets/xml/chromaprefs.xml"); 
			trace("preferences: "+prefsFile.nativePath);
			stream = new FileStream();
			// If it exists read it 
			if (prefsFile.exists) {
				trace("chroma preference file exists");
				stream.open(prefsFile, FileMode.READ);
				readXMLprefs();
			} else {
				trace("chroma preference file NOT exists");
				createXMLprefs();
			}
		}
		
		private function readXMLprefs():void 
		{
			trace("file size:"+stream.bytesAvailable);
			prefsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			//Set local variable equal to XML values
			Hue = Number(prefsXML.Hue);
			Tolerance = Number(prefsXML.Tolerance);
			Saturation = Number(prefsXML.Saturation);
			MinValue = Number(prefsXML.MinValue);
			MaxValue = Number(prefsXML.MaxValue);
			
			cupX = Number(prefsXML.cupX);
			cupY  =Number(prefsXML.cupY);
			cupWidth =Number(prefsXML.cupWidth);
			cupHeight = Number(prefsXML.cupHeight);
			
			cropX =Number(prefsXML.cropX);
			cropY =Number(prefsXML.cropY);
			cropWidth =Number(prefsXML.cropWidth);
			cropHeight =Number(prefsXML.cropHeight);
			colorPickerX=Number(prefsXML.colorPickerX);
			colorPickerY=Number(prefsXML.colorPickerY);
			autoColor=Number(prefsXML.autoColor);
			trace("Preferences:"+prefsXML.toString());
		}
		
		private function createXMLprefs():void {
			trace("creating new XML chroma file");
			Hue = 120;
			Tolerance = 45;
			Saturation = 0.2;
			MinValue = 0.35;
			MaxValue = 0.45;
			cupX = 0;
			cupY = 0;
			cupWidth = 197;
			cupHeight = 333;
			cropX = 200;
			cropY = 0;
			cropWidth = 400;
			cropHeight = 800;
			colorPickerX=0;
			colorPickerY=0;
			prefsXML=new XML();
			prefsXML = <preferences/>;
			prefsXML.Hue =  Hue.toString();
			prefsXML.Tolerance =  Tolerance.toString();
			prefsXML.Saturation =  Saturation.toString();
			prefsXML.MinValue =  MinValue.toString();
			prefsXML.MaxValue =  MaxValue.toString();
			
			prefsXML.cupX = cupX.toString();
			prefsXML.cupY = cupY.toString();
			prefsXML.cupWidth = cupWidth.toString();
			prefsXML.cupHeight = cupHeight.toString();
			
			prefsXML.cropX = cropX.toString();
			prefsXML.cropY = cropY.toString();
			prefsXML.cropWidth = cropWidth.toString();
			prefsXML.cropHeight = cropHeight.toString();
			prefsXML.colorPickerX=colorPickerX.toString();
			prefsXML.colorPickerY=colorPickerY.toString();
			prefsXML.autoColor = autoColor.toString();
			writeXMLData();
		}
		public function saveXMLPrefs():void {
			prefsXML=new XML();
			prefsXML = <preferences/>;
			prefsXML.Hue =  Hue.toString();
			prefsXML.Tolerance =  Tolerance.toString();
			prefsXML.Saturation =  Saturation.toString();
			prefsXML.MinValue =  MinValue.toString();
			prefsXML.MaxValue =  MaxValue.toString();
			
			prefsXML.cupX = cupX.toString();
			prefsXML.cupY = cupY.toString();
			prefsXML.cupWidth = cupWidth.toString();
			prefsXML.cupHeight = cupHeight.toString();
			
			prefsXML.cropX = cropX.toString();
			prefsXML.cropY = cropY.toString();
			prefsXML.cropWidth = cropWidth.toString();
			prefsXML.cropHeight = cropHeight.toString();
			prefsXML.colorPickerX=colorPickerX.toString();
			prefsXML.colorPickerY=colorPickerY.toString();
			prefsXML.autoColor = autoColor.toString();
			writeXMLData();
		}
		public function writeXMLData():void 
		{
			trace("saving xml:"+prefsXML.toXMLString());
			var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
			outputString += prefsXML.toXMLString();
			outputString = outputString.replace(/\n/g, File.lineEnding);
			trace("*********"+outputString+"***********");
			try
			{
				var f:File = new File( prefsFile.nativePath );
				stream = new FileStream();
				stream.open(f, FileMode.WRITE);
				stream.writeUTFBytes(outputString);
				stream.close();
			} catch (error:Error)
			{
				trace("error saving xml:"+error.message);
			} 
			
		}
		
	}
}