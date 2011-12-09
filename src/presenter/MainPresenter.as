package presenter
{
	import core.MediaArrangerCore;
	import core.fileIO.IFileIOObserver;
	import core.mediaInfo.Show;
	import core.scrapers.TheTVDBScraper;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;

	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.ItemClickEvent;
	import mx.events.PropertyChangeEvent;

	import view.IMainView;

	public class MainPresenter extends EventDispatcher implements IFileIOObserver
	{
		private var tv_location:String = "c:\\shows";
		private var movie_location:String = "y:";
		private var i:int = 0;
		private var m_core:MediaArrangerCore = new MediaArrangerCore();
		private var m_view:IMainView;
		private var m_previousShow:Show;
		private var m_currentShow:Show;

		private var m_file:File;
		private var m_inputDir:String = "C:\\share\\tv";
		private var m_mediaName:String;
		private var m_season:String;
		private var m_targetFolder:String;
		private var m_currentFileName:String;
		private var m_copyStatus:String;
		private var m_scraperStatus:String;
		private var m_targetBase:String = "c:\\shows";
		private var m_scrape:Boolean = false;
		private var m_recursiveScan:Boolean = true;

		private var m_movementStack:ArrayList = new ArrayList();
		private var m_copyInProgress:Boolean = false;
		private var m_files	:Vector.<String>;

		public function MainPresenter(view:IMainView)
		{
			m_view = view;
		}


		[Bindable]
		public function get recursiveScan():Boolean
		{
			return m_recursiveScan;
		}

		public function set recursiveScan(value:Boolean):void
		{
			m_recursiveScan = value;
		}

		[Bindable]
		public function get pendingFiles():IList
		{
			return m_movementStack as IList;
		}

		public function set pendingFiles(value:IList):void
		{
			m_movementStack = value as ArrayList;
		}

		[Bindable]
		public function get targetBase():String
		{
			return m_targetBase;
		}

		public function set targetBase(value:String):void
		{
			m_targetBase = value;
			updateTargetName();
		}

		[Bindable]
		public function get scrape():Boolean
		{
			return m_scrape;
		}

		public function set scrape(value:Boolean):void
		{
			m_scrape = value;
		}

		[Bindable]
		public function get scraperStatus():String
		{
			return m_scraperStatus;
		}

		public function set scraperStatus(value:String):void
		{
			m_scraperStatus = value;
		}

		[Bindable]
		public function get copyStatus():String
		{
			return m_copyStatus;
		}

		public function set copyStatus(value:String):void
		{
			m_copyStatus = value;
		}

		[Bindable]
		public function get file():File
		{
			return m_file;
		}

		public function set file(value:File):void
		{
			m_file = value;
			if (m_file)
			{
				currentFileName = m_file.nativePath;
			}
		}

		[Bindable]
		public function get currentFileName():String
		{
			return m_currentFileName;
		}

		public function set currentFileName(value:String):void
		{
			m_currentFileName = value;
		}

		[Bindable]
		public function get inputDir():String
		{
			return m_inputDir;
		}

		public function set inputDir(value:String):void
		{
			m_inputDir = value;
		}

		[Bindable]
		public function get mediaName():String
		{
			return m_mediaName;
		}

		public function set mediaName(value:String):void
		{
			m_currentShow.name = value;
			m_mediaName = value;
			updateTargetName();
		}

		[Bindable]
		public function get season():String
		{
			return m_season;
		}

		public function set season(value:String):void
		{
			m_season = value;
			updateTargetName();
		}

		[Bindable]
		public function get targetFolder():String
		{
			return m_targetFolder;
		}

		public function set targetFolder(value:String):void
		{
			m_targetFolder = value;
		}

		private function crawlFiles():void
		{
			var dir:File = new File(inputDir);
			m_files = m_core.crawlDirectory(dir, m_recursiveScan);
		}

		public function scanDirectory():void
		{
			crawlFiles();
			m_files.sort(
				// sort files by name over the entire path
				function(a:String, b:String):Number
				{
					if (a<b)
						return -1;
					if (a>b)
						return 1;
					return 0;
				}

			);
			for (var i:int=0; i<m_files.length; i++)
			{
				file = new File(m_files[i]);
				if (process())
				{
					addFileToPendingList();
				}
			}
		}

		public function beginMove():void
		{
			if (pendingFiles.length>0)
			{
				var data:Object = pendingFiles.getItemAt(0);
				(pendingFiles as ArrayList).removeItem(data);
				m_core.moveFiles(data.file.nativePath, data.location.nativePath, this);
			}
		}

		// IFileIOObserver functions
		public function moveSuccess():void
		{
			copyStatus = "Move succeeded";
			beginMove();
		}

		public function moveError(failedFile:String, reason:String):void
		{
			copyStatus = "Failed moving: "+failedFile+". "+reason;
			beginMove();
		}
		// END IFileIOObserver functions


		public function modifyFiles(selectedItems:Vector.<Object>):void
		{
			if (selectedItems.length)
			{
				m_currentShow = selectedItems[0].show;
				season 			= m_currentShow.season.toString();
				mediaName 		= m_currentShow.name;
				updateTargetName();
			}
		}

		public function applyChanges(selectedItems:Vector.<Object>):void
		{
			for each (var o:Object in selectedItems)
			{
				(o.show as Show).name = mediaName;
				(o.show as Show).season = int(season);
				o.location = new File(getTargetName(o.show));
				o.label = o.location.nativePath;
			}
		}

		public function removeFromPendingList(selectedItems:Vector.<Object>):void
		{
			for each (var o:Object in selectedItems)
			{
				m_movementStack.removeItem(o);
			}
		}

		private function addFileToPendingList():void
		{
			if (file && targetFolder)
			{
				var moveFile:File = new File(file.nativePath);
				var newLocation:File = new File(targetFolder);
				if (newLocation.exists==false)
				{
					if (scrape)
					{
						scraperStatus = "Scraping "+m_currentShow.name;
						m_core.addEventListener(Event.COMPLETE, onScrapingDone);
						m_core.generateNFO(m_currentShow, new File(showBasePath(m_currentShow)));
					}
					pendingFiles.addItem({	file:moveFile,
											location:newLocation,
											pathBase:targetBase,
											show:m_currentShow});
				}
				else
				{
					copyStatus = "File already exists, skipping";
				}
			}
		}

		private function onScrapingDone(ev:Event):void
		{
			scraperStatus = "Scraping done.";
			m_core.removeEventListener(Event.COMPLETE, onScrapingDone);
		}

		private function process():Boolean
		{
			m_currentShow = null;
			var res:Object = m_core.extractEpisodeInfo(file.name);
			if (res)
			{
				var show:Show = m_core.processShow(file.name, res);
				if (show)
				{
					applyShowData(show);
					return true;
				}
			}
			return false;
		}

		private function applyShowData(show:Show):void
		{
			m_currentShow = show;
			m_currentShow.originalName = show.name;
			applyModifiedShowName();
			season 			= m_currentShow.season.toString();
			mediaName 		= m_currentShow.name;
			updateTargetName();
			m_view.setMediaType("tv");
		}

		private function updateTargetName():void
		{
			targetFolder = getTargetName(m_currentShow);
		}

		private function getTargetName(show:Show):String
		{
			return showBasePath(show) + "\\" + "s"+show.season + "\\" + show.fileName;
		}

		private function showBasePath(show:Show):String
		{
			return targetBase + "\\" + show.name;
		}

		private function applyModifiedShowName():void
		{
			if (m_previousShow)
			{
				if (m_previousShow.originalName==m_currentShow.originalName)
				{
					m_currentShow.name = m_previousShow.name;
				}
			}
		}


		private function applyMovieData(file:File):void
		{
			m_view.setMediaType("movie");
		}
	}
}