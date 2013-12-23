package model
{
	import com.adobe.utils.StringUtil;
	import com.alfo.utils.PictureWatcher;
	import com.alfo.utils.StringUtils;
	import com.alfo.utils.WatchEvent;
	import com.utils.Console;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import events.GreenscreenEvent;
	import events.KioskProgressEvent;
	import events.KioskWaitEvent;
	
	public class GreenscreenModel extends EventDispatcher
	{
		protected var finalWatch:PictureWatcher;
		protected var data:Object;
		protected var urn:String;
		protected var team:String;
		
		protected var watchFolder:String;
		
		
		
		public function GreenscreenModel(urn:String="DEFAULT_URN", team:String="arsenal", watchFolder:String="")
		{
			Console.log("GreenscreenModel",this);
			this.urn = urn;
			this.team = team;
			
			this.watchFolder = watchFolder;
			createListeners();
			
			

		}
		public function createListeners():void
		{
			if (watchFolder!="")
			{
				// photoShop output Folder
				finalWatch=new PictureWatcher();
				finalWatch.setWatchFolder(watchFolder+"\\output");
				finalWatch.addEventListener(WatchEvent.ON_ADD_PHOTO, onPhotoReady);
			} else {
				// -> greenscreenevent
				//this.parentApplication.dispatchEvent( new KioskError(KioskError.ERROR, "Settings Error", "Please change settings" ) );
				this.dispatchEvent( new GreenscreenEvent( GreenscreenEvent.ERROR, {title: "Settings Error", message: "Please change settings" }));
			
					}

		}
		protected function writeConfig():Boolean
		{
			var urnConfigFile:File = File.applicationDirectory.resolvePath(watchFolder+"\\settings\\urn.jsx");
			var data:Object = { "URN": this.urn, "club_logo" : this.team+".png" }; 
			// need to read and replace in file
			
			if (!urnConfigFile.exists)
			{
				Console.log("File not found", this);
				return false;
			}
			var stream:FileStream = new FileStream();
			stream.open(urnConfigFile, FileMode.READ);
			
			var fileString:String = stream.readUTFBytes(stream.bytesAvailable);
			
			Console.log("fileString:"+fileString, this);
			
			var lines:Array = fileString.split(String.fromCharCode(13));
			
			for (var i:int=0;i<lines.length;i++)
			{
				//Console.log(i+"."+lines[i],this);
				for (var m:String in data)
				{
					
					if (lines[i].split("=")[0].split(" ")[1]==m) //format: var key = "value"
					{
						//Console.log(lines[i].split("=")[0]+" = \""+data[m]+"\"",this);
						lines[i] = lines[i].split("=")[0]+" = \""+data[m]+"\""; 
					}
				}
				//Console.log(i+"."+lines[i],this);
			}
			
			fileString = lines.join(String.fromCharCode(13));
			stream.close()
			stream.open(urnConfigFile, FileMode.WRITE);
			stream.writeUTFBytes(fileString);
			stream.close();
			return true;
		}

			
			
		public function send(photo:File):void
		{
			
			if (this.writeConfig())
			{
				this.dispatchEvent( new GreenscreenEvent( GreenscreenEvent.WAIT, { message: "PLEASE WAIT" }));
				finalWatch.startWatch();			
				
				//var destinationFile:File=File.applicationDirectory.resolvePath(watchFolder+"\\tmp\\ZZZZZZZZ.jpg");
				var destinationFile:File=File.applicationDirectory.resolvePath(watchFolder+"\\tmp\\"+this.urn+".jpg");
				Console.log("Copy from "+photo.nativePath+" to "+destinationFile.nativePath, this);
				photo.copyTo(destinationFile,true);
				var nativeProcessInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();
				nativeProcessInfo.executable=destinationFile;
				nativeProcessInfo.arguments=new <String>[watchFolder+"\\settings\\wrapup.jsx"];
				
				var process:NativeProcess=new NativeProcess();
				process.start(nativeProcessInfo);
				NativeApplication.nativeApplication.activate();
				
				//this.parentApplication.dispatchEvent( new KioskWaitEvent("PLEASE WAIT") );
				
			}
		}
		public function destroy():void
		{
			var photo:File = File.applicationDirectory.resolvePath(data.watchFolder+"\\tmp\\ZZZZZZZZ.jpg");
			if(photo.exists) {
				photo.deleteFile();
			}
			
			finalWatch.removeEventListener(WatchEvent.ON_ADD_PHOTO, this.onPhotoReady);
			finalWatch.stopWatch();
			//emptyCaptures();
		}
		
				
		
		protected function onPhotoReady(e:WatchEvent):void
		{
			finalWatch.stopWatch();
			this.dispatchEvent( new GreenscreenEvent( GreenscreenEvent.PHOTO_READY, {}));
		}
	}
}