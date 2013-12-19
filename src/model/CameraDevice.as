package model
{
	import com.utils.Console;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
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
	
	import events.CameraEvent;
	import events.UserEvent;
	
	import org.osmf.events.MediaElementEvent;
	
	import ru.inspirit.image.encoder.JPGAsyncEncoder;

	public class CameraDevice  extends UIComponent
	{
		protected var camera:Camera;
		protected var video:Video;
		protected var photoCapture:Bitmap;
		protected var _width:int=0;
		protected var _height:int=0;
		protected var encoder:JPGAsyncEncoder = new JPGAsyncEncoder(85);
		
		public function CameraDevice(_width:int=1280, _height:int=720)
		{
			this._width = _width;
			this._height = _height;
			this.destroy();
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
		public function destroy():void
		{
			if (video!=null)
			if (this.contains(video))
				this.removeChild( video );
			if (photoCapture!=null)
			if (this.contains(photoCapture))
				this.removeChild( photoCapture );
			
			video = null;
			camera = null;
			photoCapture = null;
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
			photoCapture = new Bitmap(bitmapData, "auto", true)
			this.addChild( photoCapture );
			video.visible = false;
			
			
			encoder.addEventListener(ProgressEvent.PROGRESS, onEncodingProgress);
			encoder.addEventListener(Event.COMPLETE, onEncodeComplete);
			encoder.encodeAsync(bitmapData);
			
			
			
			
		}
		
		private function onEncodingProgress(e:ProgressEvent):void 
		{
			//this.dispatchEvent(  
			//.text=Math.round(e.bytesLoaded/e.bytesTotal * 100).toString()+"%";
			Console.log('ENCODING PROGRESS: ' + Math.round(e.bytesLoaded/e.bytesTotal * 100) + '%', this);
		}
		protected function onEncodeComplete(e:Event) {
			var now:Date = new Date();
			var randomName:String  = "IMG" + now.fullYear + now.month +now.day +now.hours + now.minutes + now.seconds + ".jpg";
			var destFile:File = File.documentsDirectory.resolvePath("userdata/"+randomName);

			var stream:FileStream = new FileStream();
			stream = new FileStream();
			
			stream.open(destFile, FileMode.WRITE);
			stream.writeBytes(encoder.encodedImageData);
			//stream.writeUTFBytes(outputString);
			stream.close();
			
			Console.log("Image Saved: "+destFile.url, this);
			
			this.dispatchEvent( new CameraEvent( CameraEvent.COMPLETE, {file: destFile} ) );
			
		}
		public static function get isSupported():Boolean
		{
			return Camera.isSupported;
		}
	}
}