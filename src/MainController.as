	import flash.events.MouseEvent;
	import flash.filesystem.File;

	import mx.events.ItemClickEvent;

	private var tv_location:String = "z:";
	private var movie_location:String = "y:";
	private var i:int = 0;

	private function onMediaTypeChanged(ev:ItemClickEvent):void
	{
		currentState = mediaType.selection.id;
	}

	private function onScanDir(ev:MouseEvent):void
	{
		var dir:File = new File(inputDir.text);
		if (dir.exists && dir.isDirectory)
		{
			var files:Array = dir.getDirectoryListing();
			files.sortOn("name");
//			for (var i:int=0; i<files.length; i++)
//			{
				var file:File = files[i] as File;
				if (file && file.isDirectory==false)
				{
					process(file);
				}
//			}
		}
		i++;
	}

	private function process(file:File):void
	{
		trace(file.name);
		var episodeExp:RegExp = /(?:\x2E|_)?(s?\d{1,2})(?:x?|_?)(e?\d{1,2})/i;
		var res:Object = episodeExp.exec(file.name);
		if (res)
		{
			processTV(file, res);
		}
		else
		{
			processMovie(file);
		}
	}

	private function processTV(file:File, result:Object):void
	{
		currentState = "tv";
		tv.selected = true;
		seasonInput.text = result[1];
		episodeInput.text = result[2];
		var nameExp:RegExp = /([\.a-zA-Z0-9_\w]+)(s\d{1,2}|\d{3,4}|\.(\d|s)).*/i;
		var res:Object = nameExp.exec(file.name);
		if (res)
		{
			mediaName.text = res[1];
		}
		else
		{
			mediaName.text = result[0];
		}
		// Remove underscore from show name
		while (mediaName.text.indexOf("_")>0)
		{
			mediaName.text = mediaName.text.replace("_", " ");
		}
		// Remove period from show name
		while (mediaName.text.indexOf(".")>0)
		{
			mediaName.text = mediaName.text.replace(".", " ");
		}
		// Remove episode info from show name
		var episodeIndex:int = mediaName.text.indexOf(seasonInput.text+episodeInput.text);
		if (episodeIndex>-1)
		{
			mediaName.text = mediaName.text.substr(0, episodeIndex);
		}
		// Trim trailing whitepsace
		var whiteSpaceExp:RegExp =/[ \t]+$/gi;
		mediaName.text = mediaName.text.replace(whiteSpaceExp, "");

		targetFolder.text = tv_location + "\\" + mediaName.text + "\\" + seasonInput.text + "\\" + file.name;
	}

	private function processMovie(file:File):void
	{
		movie.selected = true;
		currentState = "movie";
	}
