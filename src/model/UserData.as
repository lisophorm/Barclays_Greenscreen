package model
{
	public class UserData
	{
		public function UserData()
		{
		}
		
		public var firstName : String;
		public var lastName : String;
		public var emailAddress : String;
		public var urn : String = "00000000";
		public var teamID : int;
		public var greenscreenImageName : String;
		
		public var premierLeagueOptin : Boolean = false;
		public var clubOptin : Boolean = false;
		public var barclaysOptin : Boolean = false;
	}
}