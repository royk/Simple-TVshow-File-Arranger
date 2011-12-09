package core.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.filesystem.File;

	public class ShowsSQLiteBase implements IShowsDB
	{
		protected var m_connection	:SQLConnection;
		protected var m_dbFile		:File;

		public function ShowsSQLiteBase()
		{
		}

		public function setDB(file:File):void
		{
			m_dbFile = file;
		}

		public function init():void
		{
			m_connection = new SQLConnection();
			m_connection.open(m_dbFile);
		}

		protected function startStatement(text:String):SQLStatement
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = m_connection;
			statement.text = text;
			return statement;
		}

		public function addShow(name:String):void
		{
		}

		public function getShows():Array
		{
			return null;
		}
	}
}