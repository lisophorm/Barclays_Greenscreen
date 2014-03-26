package uk.co.huydinh.events {
	import flash.events.Event;

	/**
	 * @author Huy
	 */
	public class AssetLoaderEvent extends Event {
		
		public static const HIGHEST_PRIORITY_LOADED:String = 'highest_priority_loaded';
		public static const XML_LOADED:String = 'xml_loaded';
		public static const ASSET_LOADED:String = 'asset_loaded';
		
		public var url:String;
		
		public function AssetLoaderEvent(type:String, url:String = null) {
			super(type);
			this.url = url;
		}
		
		override public function clone():Event {
			return new AssetLoaderEvent(this.type, this.url);
		}
	}
}
