package core
{
	import core.mediaInfo.Show;
	import core.utils.StringUtils;

	import mx.utils.StringUtil;

	public class MediaArrangerCore
	{
		public function MediaArrangerCore()
		{
		}

		public function extractEpisodeInfo(fileName:String):Object
		{
			return RegExpLibrary.TV_EPISODE_INFO.exec(fileName);
		}

		public function processShow(fileName:String, episodeInfo:Object):Show
		{
			var show:Show = new Show();
			show.fileName = fileName;
			if (episodeInfo.length>2)
			{
				var season:String 	= episodeInfo[1];
				var episode:String 	= episodeInfo[2];
				var name:String 	= fileName.substr(0, fileName.indexOf(episodeInfo[0]));	// just default value, in case regex fails
				var showNameRegex:Object = RegExpLibrary.TV_SHOW_NAME.exec(fileName);
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

				show.name = name;
				show.episode 	= Number(RegExpLibrary.TV_EPISODE_NUMBER.exec(episode)[1]);
				show.season 	= Number(RegExpLibrary.TV_SEASON_NUMBER.exec(season)[1]);
			}
			return show;
		}
	}
}