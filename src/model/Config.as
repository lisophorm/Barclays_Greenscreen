package model
{
	public class Config
	{
		import flash.filesystem.*;
		
		private static const PI_OVER_180 : Number = Math.PI / 180.0;
		
		public var prefsFile:File; // The preferences prefsFile
		[Bindable] public var prefsXML:XML; // The XML data
		public var stream:FileStream; // The FileStream object used to read and write prefsFile data.
		
		public var serverIP:String="";
		public var urnLength:Number=0;
		public var applicationType:String = "";
		
		public var latitide:Number;
		public var longitude:Number;
		
		public static var access_token:String;
		public static var logout:String;
		
		public var encryptPass:String;
		
		public function Config()
		{
			prefsFile = File.applicationStorageDirectory;
			prefsFile = prefsFile.resolvePath("assets/xml/preferences.xml"); 
			trace("preferences: "+prefsFile.nativePath);
			readXML();
		}
		
		private function readXML():void 
		{
			stream = new FileStream();
			// If it exists read it 
			if (prefsFile.exists) {
				trace("preference file exists");
				stream.open(prefsFile, FileMode.READ);
				processXMLData();
			}
			else //Otherwise make a file and save it
			{
				var tempFile:File = File.applicationDirectory;
				tempFile = tempFile.resolvePath("assets/xml/preferences.xml"); 
				try {
					tempFile.copyTo(prefsFile,true);
				} catch (error:Error)
				{
					trace("error saving xml for the first time:"+error.message);
				} 
				stream.open(prefsFile, FileMode.READ);
				processXMLData();
			}
			
		}
		
		private function saveData():void
		{
			createXMLData(); 
			writeXMLData();
		}
		
		private function processXMLData():void 
		{
			trace("file size:"+stream.bytesAvailable);
			prefsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			//Set local variable equal to XML values
			serverIP		= prefsXML.serverIP;
			urnLength		= prefsXML.urnLength;
			applicationType = prefsXML.applicationtype;
			
			trace("Preferences: (serverIP: '"+ serverIP + "' , urnLength: '"+urnLength+"' , applicationType: '"+applicationType+"')");
		}
		
		public function saveApplicationVariables(values:Object):void
		{
			trace("save prefs");
			if (prefsFile.exists) {
				prefsXML.aespassword = values.aespassword;
				prefsXML.serverIP 		= values.serverIP;
				prefsXML.facebookAppID  = values.facebookAppID;
				prefsXML.urnLength 		= values.urnLength;
				prefsXML.applicationtype = values.applicationtype;
				prefsXML.scoreFormat	 = values.scoreFormat;
				prefsXML.localIP	 = values.localIP;
				prefsXML.eventlocation = values.eventlocation;
				prefsXML.internetTimeout = values.internetTimeout;
				prefsXML.tabletID=values.tabletID;
				
				
				writeXMLData();
				
				//var xml = XML(stream.readUTFBytes(fileStream.bytesAvailable));
				/*
				prefsXML.applicationType = type;
				var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
				outputString += prefsXML.toXMLString();
				outputString = outputString.replace(/\n/g, File.lineEnding);
				
				fileStream.writeUTFBytes(outputString);
				fileStream.close();
				*/
			}
			else
			{
				trace("no file");
			}
		}
		public function setLocationLabel(theLabel:String):void {
			prefsXML.locationlabel=theLabel;
			
		}
		public function getLocationLabel():String {
			return prefsXML.locationlabel;
		}
		/**
		 * Creates the XML object with data based on the window state 
		 * and the current time.
		 */
		private function createXMLData():void 
		{
			prefsXML = <preferences/>;
			prefsXML.serverIP="0.0.0.0";
			prefsXML.urnLength="10";
			
		}
		
		/**
		 * Called when the NativeWindow closing event is dispatched. The method 
		 * converts the XML data to a string, adds the XML declaration to the beginning 
		 * of the string, and replaces line ending characters with the platform-
		 * specific line ending character. Then sets up and uses the stream object to
		 * write the data.
		 */
		public function writeXMLData():void 
		{
			trace("saving xml:");
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
		
		public function setPosition(lat:Number,lon:Number):void {
			prefsXML.latitude=lat.toString();
			prefsXML.longitude=lon.toString();
		}
		
		
	}
}

