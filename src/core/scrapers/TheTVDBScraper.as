package core.scrapers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	public class TheTVDBScraper extends EventDispatcher
	{
		static private const API_KEY:String = "A4CAC0CAF7DB3136";
		static private const API_PATH:String = "http://www.thetvdb.com/api/";

		static private const GET_SERIES:String = "GetSeries.php";

		private var m_location:File;

		public function TheTVDBScraper()
		{
		}

		public function generateNFO(name:String, location:File):void
		{
			var req		:URLRequest;
			var data	:URLVariables;
			var loader	:URLLoader;
			m_location = location;
			data = new URLVariables();
			data.seriesname = name;
			req = new URLRequest(API_PATH+GET_SERIES);
			req.method = URLRequestMethod.GET;
			req.data = data;
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onSeriesLoaded);
			loader.load(req);
		}

		private function onSeriesLoaded(ev:Event):void
		{
			var result	:String;
			var xml		:XML;
			if (ev.target && ev.target.data)
			{
				result = ev.target.data;
				try
				{
					xml = new XML(result);
				}
				catch(e:Error)
				{
					dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
				generateBasicNFO(xml);
			}
		}

		private function generateBasicNFO(xml:XML):void
		{
			var nfo:XML = <tvshow>
							<title></title>
							<id></id>
							<imdbid></imdbid>
							<plot></plot>
						</tvshow>;
			nfo.id[0] = xml..seriesid.text();
			nfo.imdbid[0] =xml..IMDB_ID.text();
			nfo.title[0] = xml..SeriesName.text();
			nfo.plot[0] = xml..Overview.text();
			var stream:FileStream = new FileStream();
			stream.open(m_location, FileMode.WRITE);
			stream.writeUTFBytes(nfo.toXMLString());
			stream.close();
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}