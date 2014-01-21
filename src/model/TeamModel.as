package model
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import model.entity.TeamDTO;

	public class TeamModel
	{
		private static var _instance:TeamModel;
		
		private var _teamList:Vector.<TeamDTO>;
		
		public function get teamList() : Vector.<TeamDTO>
		{
			return _teamList;
		}
		
		public function TeamModel(s:SingletonEnforcer) 
		{
			if (s == null) throw new Error("Singleton, use MySingleton.instance");
		}
		
		public static function get instance():TeamModel 
		{
			if (_instance == null) 
				_instance = new TeamModel(new SingletonEnforcer());
			return _instance;
		}
		
		public function loadTeams():void
		{
			var teamFile : File = File.applicationDirectory.resolvePath('assets/xml/teams.xml');
			
			if(teamFile.exists)
			{
				var stream : FileStream = new FileStream();
				stream.open(teamFile, FileMode.READ);
				var xml:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				
				var teamXMLList : XMLList = xml.team;
				_teamList = new Vector.<TeamDTO>();
				
				for each (var x : XML in teamXMLList)
				{
					var teamDTO : TeamDTO = new TeamDTO();
					teamDTO.teamName = x.@name;
					teamDTO.backgroundImage = x.@backgroundImage;
					teamDTO.cupImage = x.@cupImage;
					_teamList.push(teamDTO);
					trace("TeamModel :: loadTeams :: " + x.@name + " :: " + x.@cupImage + " :: " + x.@backgroundImage);
				}
			}
		}
	}
}
class SingletonEnforcer {}