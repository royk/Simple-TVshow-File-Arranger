package core.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.filesystem.File;

	public class ShowsDB implements IShowsDB
	{
		private var m_connection:SQLConnection;

		public function ShowsDB()
		{
		}

		public function init():void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("shows.db");
			m_connection = new SQLConnection();
			m_connection.open(file);

			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = m_connection;
			statement.text = "CREATE TABLE IF NOT EXISTS SHOWS (SHOW_ID INTEGER PRIMARY KEY AUTOINCREMENT, SHOW_NAME TEXT)";
			statement.execute();
		}

		public function addShow(name:String):void
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = m_connection;
			statement.text = "INSERT INTO SHOWS (SHOW_NAME) VALUES (?)";
			statement.parameters[0] = name;
			statement.execute();
		}

		public function getShows():Array
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = m_connection;
			statement.text = "SELECT * FROM SHOWS";
			statement.execute();
			return statement.getResult().data;
		}
	}
}