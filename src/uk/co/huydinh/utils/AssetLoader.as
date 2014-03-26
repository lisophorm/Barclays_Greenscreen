package uk.co.huydinh.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.utils.Dictionary;
	
	import uk.co.huydinh.events.AssetLoaderEvent;

	/**
	 * @author Huy Dinh (huyboy@gmail.com)
	 */
	public class AssetLoader extends EventDispatcher {
		
		public var max_threads : uint = 2;
		
		public var xml : XML;
		public var assets : Object = new Object();
		
		public var bytesLoaded : uint;
		public var bytesTotal : uint;
		
		private static var _instance : AssetLoader = new AssetLoader();
		
		private var _xmls : Object = new Object();
		private var _fonts : Object = new Object();
		private var _request : URLRequest = new URLRequest();
		private var _elements : Dictionary = new Dictionary();
		private var _progressEvent:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
		private var _attributes : Array;
		private var _queue : Array = [];
		private var _loading : uint = 0;
		private var _complete : Boolean = false;
		private var _baseUrl : String = './';
		
		public function get baseUrl() : String { return _baseUrl; }
		public function set baseUrl(url:String) : void { _baseUrl = url; }
		
		public function AssetLoader() {
			if (_instance) {
				throw new Error('AssetLoader is a singleton and can only be accessed by AssetLoader.getInstance()');
			}
		}
		
		public static function getInstance() : AssetLoader {
			return _instance;
		}
		
		public function load(filename:String, attributes:Array = null) : void {
			if (filename.toLowerCase().match(/\.(jpg|jpeg|png|swf|gif)$/i)) {
				var loader : Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handleAssetLoadProgress, false, 0, true);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleAssetLoadComplete, false, 0, true);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleIOError, false, 0, true);
				assets[filename] = loader;
				_elements[loader.contentLoaderInfo] = 0;
				loadAsset(filename);
			} else {
				_request.url = filename;
				var urlLoader : URLLoader = new URLLoader();
				if (attributes) {
					_attributes = attributes;
					urlLoader.addEventListener(Event.COMPLETE, handleXMLLoadComplete);
				} else {
					urlLoader.addEventListener(ProgressEvent.PROGRESS, handleAssetLoadProgress, false, 0, true);
					urlLoader.addEventListener(Event.COMPLETE, handleAssetLoadComplete, false, 0, true);
					_loading++;
					_elements[urlLoader] = 0;
					assets[filename] = urlLoader;
				}
				urlLoader.load(_request);
			}
		}
		
		private function handleXMLLoadComplete(event : Event) : void {
			xml = new XML(event.target.data);
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.XML_LOADED));
			var baseUrl : String = xml.meta.baseUrl.@path.toString();
			if (baseUrl) {
				_baseUrl = baseUrl;
			}
//			_progressEvent.bytesTotal = bytesTotal = xml.meta.bytesTotal.text().toString();
			var p:Array = [[], [], [], [], []];
			var i : uint = _attributes.length;
			var j : uint;
			var nodes:XMLList;
			var file:String;
			var size:int;
			while (i--) {
				nodes = xml..*.(hasOwnProperty('@' + _attributes[i]));
				j = nodes.length();
				while (j--) {
					var priority : String = nodes[j].@priority.toString();
					var pos : uint;
					file = nodes[j].@[_attributes[i]].toString();
					if (file) {
						switch (priority) {
							case 'highest':
								pos = 0;
								break;
							case 'high':
								pos = 1;
								break;
							case 'normal':
								pos = 2;
								break;
							case 'low':
								pos = 3;
								break;
							default:
								pos = 4;
								break;
						}
						if (p[pos].indexOf(file) == -1) {
							p[pos].push(file);
							if (!assets[file]) {
								size = nodes[j].@size.toString();
								if (size) {
									bytesTotal += size;
								}
								var loader : Loader = new Loader();
								loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handleAssetLoadProgress, false, 0, true);
								loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleAssetLoadComplete, false, 0, true);
								loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleIOError, false, 0, true);
								_elements[loader.contentLoaderInfo] = 0;
								assets[file] = loader;
							}
						}
					}
				}
			}
			
			// Move lower priority items into a queue
			var queue : Array = [];
			i = p.length;
			while (--i) {
				j = p[i].length;
				while (j--) {
					file = p[i][j];
					if (queue.indexOf(file) == -1) {
						queue.push(file);
						var obj : Object = {file:file, priority:i};
						_queue.push(obj);
					}
				}
			}
			_queue.sortOn('priority');

			_progressEvent.bytesTotal = bytesTotal;
			// Load the highest priority items straight away
			i = p[0].length;
			if (i) {
				while (i--) {
					loadAsset(p[0][i]);
				}
			} else {
				_complete = true;
				processQueue();
			}
			_attributes = null;
		}
		
		private function processQueue() : void {
			var item : Object;
			while (_queue.length && _loading < max_threads) {
				item = _queue.shift();
				loadAsset(item.file);
			}
		}
		
		private function loadAsset(file:String) : void {
			if (assets[file].contentLoaderInfo.bytesTotal == 0) {
				_request.url = _baseUrl + file;
//				_request.url = mdm.Application.path + file;
				
				assets[file].load(_request);
				_loading++;
			}
		}
		
		private function handleIOError(event : IOErrorEvent) : void
		{
			throw new Error(event.text);
		}

		private function handleAssetLoadProgress(event : ProgressEvent) : void {
			_elements[event.target] = event.bytesLoaded;
			if (_progressEvent.bytesTotal) {
				var bytes : uint = 0;
				for (var i:Object in _elements) {
					bytes += _elements[i];
				}
				_progressEvent.bytesLoaded = bytesLoaded = bytes;
				dispatchEvent(_progressEvent);
			}
		}
		
		private function handleAssetLoadComplete(event : Event) : void {
			_loading--;
			event.target.removeEventListener(ProgressEvent.PROGRESS, handleAssetLoadProgress);
			event.target.removeEventListener(Event.COMPLETE, handleAssetLoadComplete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			if (event.target is LoaderInfo) {
				var assetUrl:Array = event.target.url.split('/');
				dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.ASSET_LOADED, assetUrl[assetUrl.length -1]));
			}
			if (_complete) {
				if (0 == _loading) {
					dispatchEvent(new Event(Event.COMPLETE));
				}
				if (_queue.length > 0) {
					processQueue();
				}
			} else {
				if (0 == _loading && xml) {
					dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.HIGHEST_PRIORITY_LOADED));
					_complete = true;
					processQueue();
				}
			}
		}
		
		public function get complete() : Boolean {
			return _complete;
		}
		
		public function isLoaded(file : String) : Boolean {
			var loaderInfo : LoaderInfo = assets[file].contentLoaderInfo;
			return (loaderInfo.bytesTotal) && (loaderInfo.bytesLoaded == loaderInfo.bytesTotal);
		}
		
		public function getLoader(file : String) : Object {
			return assets[file];
		}

		public function getLoaderInfo(file : String) : LoaderInfo {
			return assets[file].contentLoaderInfo;
		}

		public function getAsset(file : String, id:String = null) : DisplayObject {
			if (id) {
				var AssetClass : Class = assets[file].contentLoaderInfo.applicationDomain.getDefinition(id) as Class;
				return new AssetClass();
			} else {
				return assets[file].content as DisplayObject;
			}
		}

		public function getClass(file : String, id:String) : Class {
			return assets[file].contentLoaderInfo.applicationDomain.getDefinition(id) as Class;
		}
		
		public function getBitmapData(file : String, id:String = null) : BitmapData {
			if (id) {
				var AssetClass : Class = assets[file].contentLoaderInfo.applicationDomain.getDefinition(id) as Class;
				return new AssetClass(0, 0) as BitmapData;
			} else {
				return assets[file].content as BitmapData;
			}
		}
		
		public function getBitmap(file : String, id:String = null) : Bitmap {
			if (id) {
				var AssetClass : Class = assets[file].contentLoaderInfo.applicationDomain.getDefinition(id) as Class;
				return new Bitmap(new AssetClass(0, 0) as BitmapData);
			} else {
				return new Bitmap(assets[file].content as BitmapData);
			}
		}
		
		public function getXML(file : String) : XML {
			if (!_xmls[file]) {
				_xmls[file] = new XML(assets[file].data);
			}
			return _xmls[file];
		}
		
		public function getFont(file:String, id:String) : Font
		{
			if (!_fonts[file + id]) {
				var FontClass : Class = assets[file].contentLoaderInfo.applicationDomain.getDefinition(id) as Class;
				Font.registerFont(FontClass);
				var font : Font = new FontClass();
				_fonts[file + id] = font;
				trace('Assetloader.getFont() - Registered font-: ' + font.fontName );
			}
			return _fonts[file + id];
		}
	}

}