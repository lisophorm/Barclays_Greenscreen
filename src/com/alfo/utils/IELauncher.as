package com.alfo.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	

	public class IELauncher
	{
		private var process:NativeProcess;
		
		public function IELauncher()
		{
			if (flash.system.Capabilities.os.indexOf("Windows")!=-1)
			{
				trace("internet explorer!!!!");
				//Console.log("Open internet explorer", this)
				var file:File=File.applicationDirectory.resolvePath("C:/Program Files (x86)/Internet Explorer");
				var nativeProcessInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
				nativeProcessInfo.executable=file;
				nativeProcessInfo.arguments=new <String>["/C "];
				
				var process:NativeProcess=new NativeProcess();
				process.start(nativeProcessInfo);
			} else 
			{
				trace("cannot launch IE - non windows platfrm");
			}
		}
		

	}
}