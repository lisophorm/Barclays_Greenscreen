package com.alfo.utils
{
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.core.UIComponent;
	
	public class GreenScreenPrefs extends UIComponent
	{
		public var prefs:SharedObject;
		public function GreenScreenPrefs()
		{
			super();
			prefs=SharedObject.getLocal("greenScreen");
			if(prefs.data.photoPath==null) {
				prefs.data.photoPath="C:\\Program Files\\Adobe\\Adobe Photoshop CS6 (64 Bit)\\Photoshop.exe";
			}
			if (prefs.data.basePath==null) {
				prefs.data.basePath=File.desktopDirectory.nativePath+"\\calibrator";
			}
		}
		public function get photoShopPath():String {
			trace("photoshop path@"+prefs.data.photoPath);
			return "C:\\Program Files\\Adobe\\Adobe Photoshop CS6 (64 Bit)\\Photoshop.exe";
		}
		
		public function set photoShopPath(thePath:String):void {
			prefs.data.photoPath=thePath;
			prefs.flush();
		}
		
		public function get basePath():String {
			trace("settings path@"+prefs.data.photoPath);
			return File.desktopDirectory.nativePath+"\\calibrator";
		}
		public function set basePath(thePath:String):void {
			prefs.data.basePath=thePath;
			prefs.flush();
		}
	}
}