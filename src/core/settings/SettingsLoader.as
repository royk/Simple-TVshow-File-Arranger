package core.settings
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class SettingsLoader
	{
		private const SETTINGS_FILE:File = File.applicationDirectory.resolvePath("settings.xml");

		public function SettingsLoader()
		{
		}

		public function load():Settings
		{
			var stream	:FileStream;
			var content	:String;
			var xml		:XML;
			var res		:Settings;
			res = new Settings();
			if (SETTINGS_FILE.exists)
			{
				stream = new FileStream();
				stream.open(SETTINGS_FILE, FileMode.READ);
				content = stream.readUTFBytes(stream.bytesAvailable);
				try
				{
					xml = new XML(content);
				}
				catch(e:Error)
				{
					// report bad file content error
				}
			}
			if (xml)
			{
				res = parseSettings(xml);
			}
			return res;
		}

		private function parseSettings(xml:XML):Settings
		{
			var settings:Settings;
			settings = new Settings();
			try
			{
				settings.inputDir 	= xml.inputDir[0].text();
				settings.outputDir 	= xml.outputDir[0].text();
				settings.xbmcDBDir	= xml.xbmcDBDir[0].text();
				settings.recursiveScan  = xml.recursiveScan[0].text().toLowerCase()=="true";
				settings.ignoreNewShows	= xml.ignoreNewShows[0].text().toLowerCase()=="true";
				settings.autoRun		= xml.autoRun[0].text().toLowerCase()=="true";
			}
			catch(e:Error)
			{
				// invalid XML structure, abort.
			}
			return settings;
		}

	}
}