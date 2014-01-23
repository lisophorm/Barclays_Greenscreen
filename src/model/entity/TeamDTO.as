package model.entity
{
	public class TeamDTO
	{
		public function TeamDTO()
		{
		}
		
		public var id : int;
		public var teamName : String;
		
		[Bindable]
		public var logoImage : String;
		public var backgroundImage : String;
		public var cupImage : String;
	}
}