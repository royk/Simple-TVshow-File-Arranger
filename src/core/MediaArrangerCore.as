package core
{
	import core.db.IShowsDB;
	import core.db.ShowsDB;
	import core.db.XBMCShowsDB;
	import core.fileIO.AIRFileIO;
	import core.fileIO.IFileIOObserver;
	import core.mediaInfo.Show;
	import core.scrapers.TheTVDBScraper;
	import core.utils.StringUtils;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	import mx.utils.StringUtil;

	public class MediaArrangerCore extends EventDispatcher
	{
		private var m_showsDB:IShowsDB;

		public function MediaArrangerCore()
		{
			m_showsDB = new XBMCShowsDB();
			m_showsDB.init();
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

		public function crawlDirectory(dir:File, recursive:Boolean):Vector.<String>
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
							if (recursive==true)
							{
								result = result.concat(crawlDirectory(file, recursive))
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
			var show:Show;
			var showNameRegex:Object = RegExpLibrary.TV_SHOW_NAME.exec(fileName);
			if (showNameRegex)
			{
				if (episodeInfo.length>2)
				{
					var season:String 	= episodeInfo[1];
					var episode:String 	= episodeInfo[2];
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
					name = StringUtils.capitalizeWords(name);
					name = StringUtil.trim(name);
					name = matchNameToDB(name, fileName, true);
					if (name)
					{
						show = new Show();
						show.fileName 	= fileName;
						show.name 		= name;
						show.episode 	= Number(RegExpLibrary.TV_EPISODE_NUMBER.exec(episode)[1]);
						show.season 	= Number(RegExpLibrary.TV_SEASON_NUMBER.exec(season)[1]);
					}

				}
			}
			return show;
		}

		private function matchNameToDB(name:String, fileName:String, failIfCantMatch:Boolean):String
		{
			var res:String = "";
			if (failIfCantMatch==false)
			{
				res = name;
			}
			if (m_showsDB)
			{
				var showNames:Array = m_showsDB.getShows();
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

			}
			return res;
		}

		public function generateNFO(show:Show, location:File):void
		{
			var scraping:Boolean = false;
			if (location.exists && location.isDirectory)
			{
				var nfo:File = new File(location.nativePath+"\\tvshow.nfo");
				if (nfo.exists==false)
				{
					var scraper:TheTVDBScraper = new TheTVDBScraper();
					scraper.addEventListener(Event.COMPLETE, onScrapingComplete);
					scraper.generateNFO(show.name, nfo);
					scraping = true;
				}
			}
			if (scraping==false)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		private function onScrapingComplete(ev:Event):void
		{
			var scraper:TheTVDBScraper = ev.target as TheTVDBScraper;
			dispatchEvent(ev);
		}
	}
}