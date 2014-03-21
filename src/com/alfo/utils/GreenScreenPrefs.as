package com.alfo.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;

	
	public class GreenScreenPrefs 
	{
		public var prefs:SharedObject;
		
		public var _trophyCoords:Rectangle;
		public var _cropCoords:Rectangle;
		private var _chromaSettings:ChromaSettings;
		
		public var prefsFile:File; // The preferences prefsFile
		[Bindable] public var prefsXML:XML; // The XML data
		public var stream:FileStream; // The FileStream object used to read and write prefsFile data.
		
		
		public function GreenScreenPrefs()
		{


		}

		

		
		public function get photoShopPath():String {
//			trace("photoshop path@"+prefs.data.photoPath);
			return "C:\\Program Files\\Adobe\\Adobe Photoshop CS6 (64 Bit)\\Photoshop.exe";
		}
		
		public function set photoShopPath(thePath:String):void {

		}
		
		public function get basePath():String {
		//	trace("settings path@"+prefs.data.photoPath);
			return File.desktopDirectory.nativePath+File.separator+"calibrator";
		}
		public function set basePath(thePath:String):void {

		}
	}
}