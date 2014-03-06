package com.alfo.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	

	public class IELauncher
	{
		private var process1:NativeProcess;
		private var process2:NativeProcess;
		public var urlAddress:String="";
		
		public function IELauncher(path:String)
		{
			this.urlAddress=path;
		}
		
		public function launch(path:String="") {
			trace("urladdress:"+urlAddress);
			if(path="") {
				path=urlAddress;
			}
			var pathArray:String;
			var partialPath:String;
			var re1:RegExp= /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/;
			var result:Object=re1.exec(urlAddress);
			trace("********* ip adress"+result);
			if (flash.system.Capabilities.os.indexOf("Windows")!=-1)
			{
				trace("internet explorer!!!!");
				//Console.log("Open internet explorer", this)
				//var file:File=File.applicationDirectory.resolvePath("C:/Program Files (x86)/Internet Explorer/iexplore.exe");
				var file:File=File.applicationDirectory.resolvePath("C:/Windows/System32/cmd.exe");
				var nativeProcessInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
				nativeProcessInfo.executable=file;
				var args:Vector.<String> = new Vector.<String>();
				args[0]="C:/Users/Alfonso/Documents/test.caz";
				//nativeProcessInfo.arguments=new <String>[result[0]+"/bio"];
				nativeProcessInfo.arguments=args;
				
				process1=new NativeProcess();
				process1.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onOutputData1);
				process1.start(nativeProcessInfo);
				
			} else 
			{
				trace("cannot launch IE - non windows platfrm");
			}
		}
		public function onOutputData1(event) 
		{ 
			var stdOut = process1.standardOutput; 
			var data = stdOut.readUTFBytes(process1.standardOutput.bytesAvailable); 
			stdOut = process1.standardError;
			var data2 = stdOut.readUTFBytes(process1.standardError.bytesAvailable); 
			trace("Got process1: ", data+ "err:"+data2); 
		}
		public function onOutputData2(event) 
		{ 
			var stdOut = process2.standardOutput; 
			var data = stdOut.readUTFBytes(process2.standardOutput.bytesAvailable); 
			trace("Got prcess2: ", data); 
		}
		public function kill(forced:Boolean=true) {
			//process.exit(forced);
			trace("internet explorer kill!!!!");
			//Console.log("Open internet explorer", this)
			var file:File=File.applicationDirectory.resolvePath("C:/Windows/System32/taskkill.exe");
			//var file:File=File.applicationDirectory.resolvePath("C:/Program Files (x86)/Internet Explorer/iexplore.exe");
			var nativeProcessInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
			nativeProcessInfo.executable=file;
			nativeProcessInfo.arguments=new <String>["/IM iexplore.exe /f"];
			
			process2=new NativeProcess();
			process2.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onOutputData2);
			process2.start(nativeProcessInfo);
		}
		

	}
}