package core
{
	import core.db.IShowsDB;
	import core.db.ShowsDB;
	import core.db.XBMCShowsDB;
	import core.fileIO.AIRFileIO;
	import core.fileIO.IFileIOObserver;
	import core.mediaInfo.Show;
	import core.settings.Settings;
	import core.settings.SettingsLoader;
	import core.utils.StringUtils;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	import mx.utils.StringUtil;

	public class MediaArrangerCore extends EventDispatcher
	{
		private var m_showsDB:IShowsDB;
		private var m_settings:Settings;

		public function MediaArrangerCore()
		{
		}

		public function init():void
		{
			settings = new SettingsLoader().load();
			m_showsDB = new XBMCShowsDB(m_settings.xbmcDB);
			m_showsDB.init();
		}
		[Bindable]
		public function set settings(value:Settings):void
		{
			m_settings = value;
		}

		public function get settings():Settings
		{
			return m_settings;
		}

		public function get showsDBAvailable():Boolean
		{
			return m_showsDB && m_showsDB.ready;
		}

		public function extractEpisodeInfo(fileName:String):Object
		{
			return RegExpLibrary.TV_EPISODE_INFO.exec(fileName);
		}

		public function moveFiles(filePath:String, toDirectoryPath:String, observer:IFileIOObserver):void
		{
			var fileIO:AIRFileIO = new AIRFileIO();
			fileIO.move(filePath, toDirectoryPath, observer);
		}

		public function crawlDirectory(dir:File):Vector.<String>
		{
			var result	:Vector.<String> 	= new Vector.<String>();
			var files	:Array;
			var file	:File;
			var i		:int;
			if (dir && dir.exists && dir.isDirectory)
			{
				files = dir.getDirectoryListing();
				files.sortOn("name");
				for (i=0; i<files.length; i++)
				{
					file = files[i] as File;
					if (file.exists)
					{
						if (file.isDirectory)
						{
							if (m_settings.recursiveScan)
							{
								result = result.concat(crawlDirectory(file))
							}
						}
						else
						{
							result.push(file.nativePath);
						}
					}
				}
			}
			return result;
		}

		public function processShow(fileName:String, episodeInfo:Object):Show
		{
			var show:Show = new Show();
			show.status = "Unable to extract show from file.";
			var showNameRegex:Object = RegExpLibrary.TV_SHOW_NAME.exec(fileName);
			if (showNameRegex)
			{

				if (episodeInfo.length>2)
				{
					var season:String 	= episodeInfo[1];
					var episode:String 	= episodeInfo[2];

					// try to see if season+episode is actually year
					var seasonEpisode:String = season.concat(episode);
					if (RegExpLibrary.NUMBER_IS_YEAR.exec(seasonEpisode))
					{
						// see if the file name contains the year
						if(fileName.indexOf(seasonEpisode)!=-1)
						{
							// match failed - the show contains year info instead of season/episode.
							return show;
						}
					}
					// if season + episode is a three number string, we need to decide which is which.
					// assume that episode is up to 20 (not sure if there's a rule for how many episodes there are in a season)
					// and that if episode is under 20, then season must be a smaller number.
					// Example: 411 will match s4 e11 instead of s41 e1.
					if (/\d{3}/.exec(seasonEpisode))
					{
						var seasonTwoNumbers:int = int(seasonEpisode.substr(0, 2));
						var episodeTwoNumbers:int = int(seasonEpisode.substr(1));
						if (episodeTwoNumbers<=20 && seasonTwoNumbers>episodeTwoNumbers)
						{
							season 	= seasonEpisode.charAt(0);
							episode = seasonEpisode.substr(1);
						}
					}
					show.status = "OK";
					var name:String 	= fileName.substr(0, fileName.indexOf(episodeInfo[0]));	// just default value, in case regex fails
					if (showNameRegex)
					{
						var extraInfoIndex:int = fileName.indexOf(showNameRegex[0]);
						if (extraInfoIndex>0)
						{
							// remove episode info and trailing junk from show name
							name = fileName.substr(0, extraInfoIndex);
						}
					}
					name = StringUtils.globalReplace(name, "_", " ");
					name = StringUtils.globalReplace(name, ".", " ");
					name = name.replace(RegExpLibrary.NAME_SEPARATOR, "");
					name = StringUtils.globalReplace(name, "-", " ");
					name = StringUtils.capitalizeWords(name);
					name = StringUtil.trim(name);
					var dbMatch:String = "";
					dbMatch = matchNameToDB(name, fileName);
					if (dbMatch=="")
					{
						// Try adding "the " to name (i.e. "big bang theory" will be matched with "the bing bang theory")
						dbMatch = matchNameToDB("The "+name, fileName);
						if (dbMatch=="")
						{
							// try removing numbers from name (i.e. Family Guy1 will be matched with Family Guy)
							dbMatch = matchNameToDB(name.replace(RegExpLibrary.NUMBER_TRIM, ""), fileName);
						}
					}
					if (dbMatch=="")
					{
						if (m_settings.ignoreNewShows)
						{
							name = "";
							show.status = "Show skipped: Not in the Database";
						}
					}
					else
					{
						name = dbMatch;
					}
					// if conntected to db but no match from db, mark show as new.

					if (name)
					{
						show = new Show();
						if (m_showsDB.getShows().length!=0 && dbMatch=="")
						{
							show.isNew = true;
						}
						show.fileName 	= fileName;
						show.name 		= name;
						show.episode 	= Number(RegExpLibrary.TV_EPISODE_NUMBER.exec(episode)[1]);
						show.season 	= Number(RegExpLibrary.TV_SEASON_NUMBER.exec(season)[1]);
					}
					else
					{
						show.status = "Unable to extract show from file.";
					}
				}
			}
			return show;
		}

		private function matchNameToDB(name:String, fileName:String):String
		{
			var res:String = "";
			if (m_showsDB==null)
			{
				// db doesn't exist - can't attempt to match. return name to pretend we had a match.
				return name;
			}
			var showNames:Array = m_showsDB.getShows();
			if (showNames.length==0)
			{
				// db empty or not found - can't attempt to match.
				return name;
			}
			if (showNames.indexOf(name)==-1)
			{
				var i			:int;
				var j			:int;
				var showName	:String;
				// try matching initials if the name is multiword, or partial match for a single word show name
				// (i.e. "Family Guy" will try to match "FG", "Dexter" will try to match "DEX")
				for (i=0; i<showNames.length; i++)
				{
					showName = showNames[i];
					var parts:Array = showName.split(" ");
					if (parts.length>1)
					{
						// try initial matching
						showName = "";
						for (j=0; j<parts.length; j++)
						{
							showName += (parts[j] as String).charAt(0);
						}
						if (showName==name)
						{
							// matched initials
							return showNames[i];
						}
					}
					else
					{
						if (showName.toLowerCase().indexOf(name.toLowerCase())!=-1)
						{
							// matched shortened show name
							return showName;
						}
						var origNameParts:Array = name.split(" ");
						if (origNameParts.length>parts.length)
						{
							for each(var innerWord:String in origNameParts)
							{
								if (showName.toLowerCase()==innerWord.toLowerCase())
								{
									// match original name contains the show name within it
									return showName;
								}
							}
						}
					}
				}
			}
			else
			{
				// if show name is an exact match to what's stored
				res = name;
			}
			return res;
		}

	}
}