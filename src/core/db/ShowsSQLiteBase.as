package core.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.filesystem.File;

	public class ShowsSQLiteBase implements IShowsDB
	{
		protected var m_connection	:SQLConnection;
		protected var m_dbFile		:File;
		protected var m_inited		:Boolean = false;

		public function ShowsSQLiteBase()
		{
		}

		public function setDB(file:File):void
		{
			m_dbFile = file;
		}

		public function init():void
		{
			if (m_dbFile.exists && m_dbFile.isDirectory==false)
			{
				m_connection = new SQLConnection();
				try
				{
					m_connection.open(m_dbFile);
				}
				catch(e:Error)
				{
					// handle db reading error
					return;
				}
				m_inited = true;
			}
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