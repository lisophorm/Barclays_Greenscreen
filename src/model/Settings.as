package model
{
	public class Settings
	{
		
		public function Settings(s:SingletonEnforcer) 
		{
			if (s == null) throw new Error("Singleton, use MySingleton.instance");
		}
		
		public static function get instance():Settings 
		{
			if (_instance == null) 
				_instance = new Settings(new SingletonEnforcer());
			return _instance;
		}
		
		private static var _instance:Settings;
		
		public static var cameraID : int = 0;
		
		private var _userData : UserData = new UserData();
		
		[Bindable]
		public function set userData(value:UserData):void 
		{
			_userData = value;
		}
		
		public function get userData():UserData 
		{
			return _userData;
		}
		
		[Bindable]
		public var cameraViewWidth : int = 800;
		
		[Bindable]
		public var cameraViewHeight : int = 600;
		
		
		[Bindable]
		public var calibratorViewWidth : int = 800;
		
		[Bindable]
		public var calibratorViewHeight : int = 600;
		
		[Bindable]
		public var imageOutputMultiplier : int = 3;
		
		
		private var _cameraSettings : Array;
		
		public function get cameraSettings():Array 
		{
			return _cameraSettings;
		}
		
		public function set cameraSettings(value : Array) : void
		{
			_cameraSettings = value;
		}
		
		private var _localURL : String;
		
		[Bindable]
		public function set localURL(value : String):void
		{
			_localURL = value;
		}
		
		public function get localURL() : String
		{
			return _localURL;
		}
	}
}
class SingletonEnforcer {}