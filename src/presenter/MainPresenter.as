package presenter
{
	import core.MediaArrangerCore;
	import core.mediaInfo.Show;
	import core.scrapers.TheTVDBScraper;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;

	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.ItemClickEvent;

	import view.IMainView;

	public class MainPresenter extends EventDispatcher
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

		private var m_movementStack:ArrayList = new ArrayList();
		private var m_copyInProgress:Boolean = false;
		private var m_files:Array;

		public function MainPresenter(view:IMainView)
		{
			m_view = view;
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
			m_files = new Array();
			var dir:File = new File(inputDir);
			crawlDir(dir);
		}

		private function crawlDir(dir:File):void
		{
			if (dir.exists && dir.isDirectory)
			{
				var files:Array = dir.getDirectoryListing();
				files.sortOn("name");
				for (var i:int=0; i<files.length; i++)
				{
					var _file:File = files[i] as File;
					if (_file.exists)
					{
						if (_file.isDirectory)
						{
							crawlDir(_file);
						}
						else
						if (_file.extension!="nfo")
						{
							var toAdd:Boolean = true;
							for (var j:int=0; j<pendingFiles.length; j++)
							{
								var toMove:Object = (pendingFiles.getItemAt(j) as Object);
								if (toMove.file.nativePath==_file.nativePath)
								{
									toAdd = false;
									break;
								}
							}
							if (toAdd)
							{
								file = _file;
								process();
								addShowToPendingList();
							}
						}
					}
				}
			}
		}

		public function scanNextFile(movePreviousFile:Boolean=true):void
		{
			if (movePreviousFile)
			{
				addFileToPendingList();
			}
			m_previousShow = m_currentShow;
			m_currentShow = null;
			if (m_files==null || m_files.length==0)
			{
				crawlFiles();
				m_files.sortOn("name");
			}
			if (m_files.length)
			{
				file = m_files.shift();
				process();
			}
		}

		public function beginMove():void
		{
			if (pendingFiles.length>0)
			{
				var data:Object = pendingFiles.getItemAt(0);
				moveFiles(data.file, data.location);
				(pendingFiles as ArrayList).removeItem(data);
			}
		}

		public function modifyFiles(selectedItems:Vector.<Object>):void
		{
			if (selectedItems.length)
			{
				var show:Show = selectedItems[0].show;
				season 			= show.season.toString();
				mediaName 		= show.name;
				updateTargetName();
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
						m_core.generateNFO(m_currentShow, new File(showBasePath));
					}
					pendingFiles.addItem({file:moveFile, location:newLocation, label:newLocation.nativePath, show:m_currentShow});
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

		private function moveFiles(moveFile:File, newLocation:File):void
		{
			m_copyInProgress = true;
			copyStatus = "Moving to: "+newLocation.nativePath;
			moveFile.moveToAsync(newLocation);
			moveFile.addEventListener(Event.COMPLETE, onMoveComplete);
			moveFile.addEventListener(IOErrorEvent.IO_ERROR, onMoveError);
		}

		private function onMoveComplete(ev:Event):void
		{
			var moveFile:File = ev.target as File;
			if (moveFile)
			{
				moveFile.removeEventListener(Event.COMPLETE, onMoveComplete);
				moveFile.removeEventListener(IOErrorEvent.IO_ERROR, onMoveError);
			}
			m_copyInProgress = false;
			copyStatus = "Completed";
			beginMove();
		}

		private function onMoveError(ev:IOErrorEvent):void
		{
			var moveFile:File = ev.target as File;
			if (moveFile)
			{
				moveFile.removeEventListener(Event.COMPLETE, onMoveComplete);
				moveFile.removeEventListener(IOErrorEvent.IO_ERROR, onMoveError);
			}
			m_copyInProgress = false;
			copyStatus = "Error: "+ev.text;
			beginMove();
		}

		private function process():void
		{
			var res:Object = m_core.extractEpisodeInfo(file.name);
			if (res)
			{
				var show:Show = m_core.processShow(file.name, res);
				applyShowData(show);
			}
			else
			{
				applyMovieData(file);
			}
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
			targetFolder = showBasePath + "\\" + "s"+m_currentShow.season + "\\" + m_currentShow.fileName;
		}

		private function get showBasePath():String
		{
			return targetBase + "\\" + m_currentShow.name;
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