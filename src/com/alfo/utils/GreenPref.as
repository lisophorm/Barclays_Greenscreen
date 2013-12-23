package com.alfo.utils
{
	import flash.filesystem.File;
	
	import mx.core.UIComponent;
	
	public class GreenPref extends UIComponent
	{
		public var photoShopPath:String="C:\\Program Files\\Adobe\\Adobe Photoshop CS5.1 (64 Bit)\\Photoshop.exe";
		public var basePath:String=File.desktopDirectory.nativePath+"\\calibrator";
		public function GreenPref()
		{
			super();
		}
	}
}