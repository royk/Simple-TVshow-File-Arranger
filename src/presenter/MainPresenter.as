package presenter
{
	import core.MediaArrangerCore;
	import core.fileIO.IFileIOObserver;
	import core.mediaInfo.Show;
	import core.settings.Settings;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;

	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.ItemClickEvent;
	import mx.events.PropertyChangeEvent;

	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.List;

	import view.IMainView;
	import view.defaultView.itemRenderers.ShowsDisplayList;

	public class MainPresenter extends EventDispatcher implements IFileIOObserver
	{
		private var m_parallelMoves:int = 0;
		private var tv_location:String = "c:\\shows";
		private var i:int = 0;
		private var m_core:MediaArrangerCore = new MediaArrangerCore();
		private var m_view:IMainView;
		private var m_previousShow:Show;
		private var m_currentShow:Show;

		private var m_file:File;
		private var m_currentFileName:String;
		private var m_log:String = "";
		private var m_targetPath:String = "";

		private var m_displayList:ShowsDisplayList = new ShowsDisplayList();
		private var m_copyInProgress:Boolean = false;
		private var m_files	:Vector.<String>;

		public function MainPresenter(view:IMainView)
		{
			m_view = view;
		}

		public function init():void
		{
			m_core.init();
			if (settings.autoRun)
			{
				scanDirectory();
				moveNextFile();
			}
		}

		public function get settings():Settings
		{
			return m_core.settings;
		}


		[Bindable]
		public function get recursiveScan():Boolean
		{
			return m_core.settings.recursiveScan;
		}

		public function set recursiveScan(value:Boolean):void
		{
			m_core.settings.recursiveScan = value;
		}

		[Bindable]
		public function get pendingFiles():IList
		{
			return m_displayList;
		}

		public function set pendingFiles(value:IList):void
		{
			m_displayList.list = value as ArrayList;
		}

		[Bindable]
		public function get targetPath():String
		{
			return m_targetPath;
		}

		public function set targetPath(value:String):void
		{
			m_targetPath = value;
			updateTargetName();
		}

		[Bindable]
		public function get log():String
		{
			return m_log;
		}

		public function set log(value:String):void
		{
			m_log = value;
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
			return m_core.settings.inputDir;
		}

		public function set inputDir(value:String):void
		{
			m_core.settings.inputDir = value;
		}

		public function parseSettings(args:Array):void
		{
			var pair:Array;
			for each (var s:String in args)
			{
				pair = s.split("=");
				if (pair.length>1 && m_core.settings.hasOwnProperty(pair[0]))
				{
					if (m_core.settings[pair[0]] is Boolean)
					{
						m_core.settings[pair[0]] = (pair[1]=="true");
					}
					else
					{
						m_core.settings[pair[0]] = pair[1];
					}
				}
			}
		}

		public function scanDirectory():void
		{
			writeLog("Scanning "+m_core.settings.inputDir+". Recursive: "+m_core.settings.recursiveScan);
			checkDBStatus();
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
			scanFilesForShows();
		}

		private function checkDBStatus():void
		{
			if (m_core.showsDBAvailable==false && m_core.settings.ignoreNewShows)
			{
				writeLog("** Can't access shows Database. Will not ignore new shows");
			}
		}

		private function crawlFiles():void
		{
			var dir:File = new File(inputDir);
			m_files = m_core.crawlDirectory(dir);
		}

		private function scanFilesForShows():void
		{
			var result:String;
			for (var i:int=0; i<m_files.length; i++)
			{
				file = new File(m_files[i]);
				writeLog("Processing "+file.name);
				result = process();
				if (result=="OK")
				{
					addFileToPendingList();
				}
				else
				{
					writeLog("\t"+result);
				}
			}
		}

		private function addFileToPendingList():void
		{
			if (file && settings.outputDir)
			{
				var moveFile:File = new File(file.nativePath);
				var newLocation:File = new File(targetPath);
				if (newLocation.exists==false)
				{
					m_displayList.moveList.addItem({	file:moveFile,
						location:newLocation,
						pathBase:settings.outputDir,
						show:m_currentShow});
				}
				else
				{
					writeLog("\tFile already exists at target path, skipping");
				}
			}
		}

		public function moveNextFile():void
		{
			if (m_displayList.moveList.length>0)
			{

				m_view.disableUI();
				m_view.showLog();
				if (m_parallelMoves==0)
				{
					writeLog("Starting files move.");
				}
				var data:Object = m_displayList.moveList.getItemAt(0);
				m_displayList.moveList.removeItem(data);
				m_core.moveFiles(data.file.nativePath, data.location.nativePath, this);
				m_parallelMoves++;
				moveNextFile();
			}
		}

		// IFileIOObserver functions
		public function moveSuccess():void
		{
			trace("moveSuccess");
			writeLog("Moved file. Files left: "+(m_parallelMoves-1));
			checkIfMoveDone();
		}

		public function moveError(failedFile:String, reason:String):void
		{
			trace("moveError");
			writeLog("\tFailed moving: "+failedFile+". "+reason);
			checkIfMoveDone();
		}
		// END IFileIOObserver functions

		private function checkIfMoveDone():void
		{
			m_parallelMoves--;
			if (m_parallelMoves==0)
			{
				m_view.enableUI();
				// moved all files
				writeLog("File moving done.");
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		public function fillModificationDataFromSelection(selectedItems:Vector.<Object>):void
		{
			if (selectedItems.length)
			{
				if (selectedItems[0].hasOwnProperty("show"))
				{
					m_currentShow = selectedItems[0].show;
					m_view.editedShow = m_currentShow;
					updateTargetName();
				}
			}
		}

		public function applyModificationToSelection(selectedItems:Vector.<Object>, changeName:Boolean, changeSeason:Boolean):void
		{
			for each (var o:Object in selectedItems)
			{
				if (changeName)
				{
					(o.show as Show).name = m_view.showName;
				}
				if (changeSeason)
				{
					(o.show as Show).season = m_view.season;
				}
				o.location = new File(getTargetName(o.show));
				o.label = o.location.nativePath;
				m_displayList.moveList.itemUpdated(o);
			}
		}

		private function writeLog(value:String):void
		{
			log += value;
			log += "\n";
		}

		private function process():String
		{
			m_currentShow = null;
			var res:Object = m_core.extractEpisodeInfo(file.name);
			if (res)
			{
				var show:Show = m_core.processShow(file.name, res);
				if (show && show.status=="OK")
				{
					applyShowData(show);
				}
				return show.status;
			}
			return "Unable to extract show from file.";
		}

		private function applyShowData(show:Show):void
		{
			m_currentShow = show;
			m_currentShow.originalName = show.name;
			applyModifiedShowName();
			updateTargetName();
		}

		private function updateTargetName():void
		{
			targetPath = getTargetName(m_currentShow);
		}

		private function getTargetName(show:Show):String
		{
			return showBasePath(show) + "\\" + "s"+show.season + "\\" + show.fileName;
		}

		private function showBasePath(show:Show):String
		{
			return settings.outputDir + "\\" + show.name;
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
	}
}