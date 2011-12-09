package core.db
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.filesystem.File;

	public class XBMCShowsDB extends ShowsSQLiteBase
	{
		private var m_showNames:Array;

		public function XBMCShowsDB()
		{
		}

		override public function init():void
		{
			setDB(new File("C:\\Program Files\\XBMC\\userdata\\Database\\MyVideos34.db"));
			super.init();
		}

		override public function addShow(name:String):void
		{
		}

		protected function generateShowNames():Array
		{
			var statement:SQLStatement;
			var res:Array;
			statement = startStatement("SELECT * FROM tvshow");
			try
			{
				statement.execute();
			}
			catch(e:Error)
			{
				// query failed.
			}
			res = extractShowNames(statement.getResult().data);
			return res;
		}

		private function extractShowNames(queryResult:Array):Array
		{
			var res:Array = new Array();
			for each (var o:Object in queryResult)
			{
				res.push(o.c00);
			}
			return res;
		}

		/**
		 * Fetches show names from DB. Caches the result.
		 */
		override public function getShows():Array
		{
			if (m_showNames==null)
			{
				m_showNames = generateShowNames();
			}
			return m_showNames;
		}

	}
}