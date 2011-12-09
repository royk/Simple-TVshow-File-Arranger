package core.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.filesystem.File;

	public class ShowsDB extends ShowsSQLiteBase
	{
		public function ShowsDB()
		{
		}

		override public function init():void
		{
			setDB(File.applicationStorageDirectory.resolvePath("shows.db"));
			super.init();

			var statement:SQLStatement = startStatement("CREATE TABLE IF NOT EXISTS SHOWS (SHOW_ID INTEGER PRIMARY KEY AUTOINCREMENT, SHOW_NAME TEXT)");
			statement.execute();
		}

		override public function addShow(name:String):void
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = m_connection;
			statement.text = "INSERT INTO SHOWS (SHOW_NAME) VALUES (?)";
			statement.parameters[0] = name;
			statement.execute();
		}

		override public function getShows():Array
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = m_connection;
			statement.text = "SELECT * FROM SHOWS";
			statement.execute();
			return statement.getResult().data;
		}
	}
}