package model
{
	import com.adobe.images.JPGEncoder;
	import com.utils.Console;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Camera;
	import flash.media.MediaPromise;
	import flash.media.Video;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	
	import org.osmf.events.MediaElementEvent;

	public class CameraDevice  extends UIComponent
	{
		protected var camera:Camera;
		protected var video:Video;
		protected var photoCapture:Bitmap;
		protected var _width:int=0;
		protected var _height:int=0;
		public function CameraDevice(_width:int=640, _height:int=480)
		{
			this._width = _width;
			this._height = _height;
			this.init()
		}
		
		protected function init():void
		{
			
			
			camera= Camera.getCamera();
			if (camera!=null)
			{
				camera.addEventListener(StatusEvent.STATUS, statusHandler); 

				camera.setMode(_width, _height, 25); 
				camera.setQuality(0,100);
				video = new Video(_width, _height);
				video.attachCamera(camera); 
				this.addChild(video);
				
				this.width = _width;
				this.height = _height;
				this.onAllowClick();
			} else {
				
			}
			
		}
		protected function statusHandler( e:StatusEvent ):void
		{
			
			Console.log( e.code, camera);
			if (camera.muted) 
			{ 
				this.onAllowClick();
			} else 
			{ 
				this.onDenyClick(); 
			} 
		}
		protected function onAllowClick():void
		{
			Console.log("onAllowClick", this);
			this.onDenyClick();
			this.addEventListener( MouseEvent.CLICK, takePhoto);
			this.mouseEnabled = this.buttonMode = true;
		}
		protected function onDenyClick():void
		{
			this.removeEventListener( MouseEvent.CLICK, takePhoto);
			this.mouseEnabled = this.buttonMode = false;
		}
			
		protected function takePhoto( e:Event = null ):void
		{
			// save file
			
			var bitmapData:BitmapData = new BitmapData(_width, _height);
			bitmapData.draw(video);
			
			var encoder:JPGEncoder = new JPGEncoder();
			var byteArray:ByteArray = encoder.encode(bitmapData);
		//	var fileReference:FileReference = new FileReference();
		//	fileReference.save(byteArray);
			; 
			var f:File = File.applicationDirectory.resolvePath("assets/userdata/test.jpg");
		
			var stream:FileStream = new FileStream();
			stream = new FileStream();
			
			stream.open(f, FileMode.WRITE);
			stream.writeBytes(byteArray);
			//stream.writeUTFBytes(outputString);
			stream.close();
			
			photoCapture = new Bitmap(bitmapData, "auto", true)
			this.addChild( photoCapture );
			video.visible = false;
			Console.log("Image Saved",this);
			//make media event
			/*
			var m:MediaEvent = new MediaEvent(MediaEvent.COMPLETE);
			var data:MediaPromise = new MediaPromise();
			
			var loader:Loader = new Loader();
			
			
			
			
			this.dispatchEvent( m );
			*/
		}
		public static function get isSupported():Boolean
		{
			return Camera.isSupported;
		}
	}
}