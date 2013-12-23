package model
{
	import com.greensock.TweenMax;
	import com.utils.Console;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.system.Capabilities;
	
	import mx.core.UIComponent;
	import mx.utils.DisplayUtil;
	
	import events.CameraEvent;
	
	import ru.inspirit.image.encoder.JPGAsyncEncoder;

	public class CameraDevice extends UIComponent
	{
		protected var camera:Camera;
		protected var video:Video;
		protected var photoCapture:Bitmap;
		protected var _width:int=0;
		protected var _height:int=0;
		protected var encoder:JPGAsyncEncoder = new JPGAsyncEncoder(85);
		protected var bitmapData:BitmapData;
		protected var overlay:Sprite;
		protected var mat:Matrix=new Matrix();
		protected var URN:String = "";
		public function CameraDevice(_width:int=320, _height:int=240, URN:String = "")
		{
			this._width = _width;
			this._height = _height;
			this.URN = URN;
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
				video = new Video(_width*4, _height*4);
				video.attachCamera(camera); 
				bitmapData = new BitmapData(_width, _height);
				photoCapture = new Bitmap(bitmapData, "auto", true);
				this.addChild( photoCapture );
				
				mat.scale(_width/video.width,_height/video.height);
				mat.translate(0,0);
				
				//this.addChild(video);
				
				this.width = _width;
				this.height = _height;
				this.onAllowClick();
			} else {
				
			}
			
		}
		public function destroy():void
		{
			this.removeEventListener( Event.ENTER_FRAME, updatePhoto );
			if (video!=null) {
				video.attachCamera(null);
				if (this.contains(video))
					this.removeChild( video );

			}
			
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
			this.addEventListener( Event.ENTER_FRAME, updatePhoto);
			this.mouseEnabled = this.buttonMode = true;
			
		}
		protected function onDenyClick():void
		{
			this.removeEventListener( MouseEvent.CLICK, takePhoto);
			this.mouseEnabled = this.buttonMode = false;
		}
			
		protected function updatePhoto( e:Event = null ):void
		{

			photoCapture.bitmapData.draw( video, mat );
		
			
			
		}
		public function takePhoto( e:Event = null ):void
		{
			// save file
			this.removeEventListener( Event.ENTER_FRAME, updatePhoto );
			var finalCapture:BitmapData = new BitmapData(video.width, video.height);
			finalCapture.draw( video );
			video.visible = false;
			video.attachCamera(null);
			if (this.contains( video))
				this.removeChild( video );
			camera = null;
			video = null;
			
			overlay = new Sprite();
			overlay.graphics.beginFill(0xFFFFFF,1);
			overlay.graphics.drawRect(0,0, _width, _height);
			overlay.graphics.endFill();
			this.addChild( overlay );
			TweenMax.to( overlay, 1.5, { alpha:0, onComplete: hideOverlay});
			
			encoder.addEventListener(ProgressEvent.PROGRESS, onEncodingProgress);
			encoder.addEventListener(Event.COMPLETE, onEncodeComplete);
			encoder.encodeAsync(finalCapture);
			
			
		}
		protected function hideOverlay( e:Event=null ):void
		{
			this.removeChild( overlay );
			overlay = null;
		}
		
		private function onEncodingProgress(e:ProgressEvent):void 
		{
			//this.dispatchEvent(  
			//.text=Math.round(e.bytesLoaded/e.bytesTotal * 100).toString()+"%";
			this.dispatchEvent( new CameraEvent( CameraEvent.PROGRESS, {title:'ENCODING PROGRESS: ', message: Math.round(e.bytesLoaded/e.bytesTotal * 100) + '%'} ) )
			Console.log('ENCODING PROGRESS: ' + Math.round(e.bytesLoaded/e.bytesTotal * 100) + '%', this);
		}
		protected function onEncodeComplete(e:Event):void 
		{
			encoder.removeEventListener(ProgressEvent.PROGRESS, onEncodingProgress);
			encoder.removeEventListener(Event.COMPLETE, onEncodeComplete);

			var now:Date = new Date();
			var randomName:String  = "IMG" + now.fullYear + now.month +now.day +now.hours + now.minutes + now.seconds + ".jpg";
			var destFile:File = File.documentsDirectory.resolvePath("userdata/"+( URN=="" ? URN : randomName ));

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