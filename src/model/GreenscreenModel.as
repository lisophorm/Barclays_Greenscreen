package model
{
	import com.alfo.utils.PictureWatcher;
	import com.alfo.utils.WatchEvent;
	import com.utils.Console;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import events.GreenscreenEvent;
	
	public class GreenscreenModel extends EventDispatcher
	{
		protected var finalWatch:PictureWatcher;
		protected var data:Object;
		protected var urn:String;
		protected var team:String;
		
		protected var watchFolder:String;
		
		protected var destinationFile:File;
		protected var photo:File		
		
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
				finalWatch.setWatchFolder( watchFolder+"\\output" );				
				finalWatch.addEventListener( WatchEvent.ON_ADD_PHOTO, onPhotoReady );
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
			
			if (this.writeConfig()) // writes the urn.jsx configuration file with data for photoshop processing
			{
				this.dispatchEvent( new GreenscreenEvent( GreenscreenEvent.WAIT, { message: "PLEASE WAIT" })); //display wait dialogue
				
				finalWatch.startWatch();	// actively begin directory watch		
				
				//var destinationFile:File=File.applicationDirectory.resolvePath(watchFolder+"\\tmp\\ZZZZZZZZ.jpg");
				destinationFile=File.applicationDirectory.resolvePath(watchFolder+"tmp\\"+this.urn+".jpg");
				Console.log("Copy from "+photo.nativePath+" to "+destinationFile.nativePath, this);
				photo.copyTo(destinationFile,true); //copy photo
				this.photo = photo;
				var nativeProcessInfo:NativeProcessStartupInfo=new NativeProcessStartupInfo();

				// for some reason these parameters are valid as opposed to those lifed of the NBA application
				// path to photoshop should be in configuration
				nativeProcessInfo.executable = new File("C:\\Program Files (x86)\\Adobe\\Adobe Photoshop CS6\\Photoshop.exe");
				nativeProcessInfo.arguments=new <String>[""+watchFolder+"settings\\wrapup.jsx"];
				//nativeProcessInfo.executable=destinationFile;
				//nativeProcessInfo.arguments=new <String>[watchFolder+"settings\\wrapup.jsx"];
				Console.log(nativeProcessInfo.executable.nativePath+" "+nativeProcessInfo.arguments[0], this);
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
			Console.log("Photo is ready!!!", this);
			finalWatch.stopWatch();
			var finalFile:File=File.applicationDirectory.resolvePath(watchFolder+"output\\"+this.urn+".jpg");
			var destFile:File = File.applicationDirectory.resolvePath(watchFolder+"destination\\"+this.urn+".jpg");
			//var destFile:File = File.documentsDirectory.resolvePath("userdata/"+this.urn+"_greenscreen.jpg" );
			finalFile.copyTo(destFile,true); //copy photo
			
			this.dispatchEvent( new GreenscreenEvent( GreenscreenEvent.PHOTO_READY, {file: destFile}));
		}
	}
}