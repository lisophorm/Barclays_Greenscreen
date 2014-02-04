package views.components.calibrator
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	
	import ru.inspirit.image.encoder.JPGAsyncEncoder;

	public class ImageCapture
	{
		private var _outputPath : String;
		private var _captureRectangle:Rectangle;
		private var encoder:JPGAsyncEncoder;
		
		public function ImageCapture(outputPath : String, captureRectangle : Rectangle)
		{
			_outputPath = outputPath;
			_captureRectangle = captureRectangle;
			encoder = new JPGAsyncEncoder(85);
		}
		
		public function writeFileFromBitmapData(bitmapData : BitmapData) : void
		{
			encoder.addEventListener(Event.COMPLETE, encodingCompleteHandler);
			encoder.encodeAsync(bitmapData);
		}
		
		protected function encodingCompleteHandler(event : Event) : void
		{
			encoder.removeEventListener(Event.COMPLETE, encodingCompleteHandler);
			var destinationFile : File = File.applicationDirectory.resolvePath(_outputPath);
			var stream : FileStream = new FileStream();
			stream.open(destinationFile, FileMode.WRITE);
			stream.writeBytes(encoder.encodedImageData);
			stream.close();
		}
	}
}