package presenter
{
	import core.MediaArrangerCore;
	import core.fileIO.IFileIOObserver;
	import core.mediaInfo.Show;

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
		private var i:int = 0;
		private var m_core:MediaArrangerCore = new MediaArrangerCore();
		private var m_view:IMainView;
		private var m_previousShow:Show;
		private var m_currentShow:Show;

		private var m_file:File;
		private var m_mediaName:String;
		private var m_season:String;
		private var m_currentFileName:String;
		private var m_log:String;
		private var m_targetPath:String = "";

		private var m_movementStack:ArrayList = new ArrayList();
		private var m_copyInProgress:Boolean = false;
		private var m_files	:Vector.<String>;

		public function MainPresenter(view:IMainView)
		{
			m_view = view;
		}

		public function init():void
		{
			m_core.init();
			if (autoRun)
			{
				scanDirectory();
				beginMove();
			}
		}


		public function get autoRun():Boolean
		{
			return m_core.settings.autoRun;
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
			return m_movementStack as IList;
		}

		public function set pendingFiles(value:IList):void
		{
			m_movementStack = value as ArrayList;
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
		public function get outputDir():String
		{
			return m_core.settings.outputDir;
		}

		public function set outputDir(value:String):void
		{
			m_core.settings.outputDir = value;
		}

		private function crawlFiles():void
		{
			var dir:File = new File(inputDir);
			m_files = m_core.crawlDirectory(dir);
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
						m_core.settings[pair[0]] = pair[1]=="true";
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
			else
			{
				// moved all files
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		// IFileIOObserver functions
		public function moveSuccess():void
		{
			writeLog("Move succeeded");
			beginMove();
		}

		public function moveError(failedFile:String, reason:String):void
		{
			writeLog("Failed moving: "+failedFile+". "+reason);
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
			if (file && outputDir)
			{
				var moveFile:File = new File(file.nativePath);
				var newLocation:File = new File(targetPath);
				if (newLocation.exists==false)
				{
					pendingFiles.addItem({	file:moveFile,
											location:newLocation,
											pathBase:outputDir,
											show:m_currentShow});
				}
				else
				{
					writeLog("File already exists, skipping");
				}
			}
		}

		private function writeLog(value:String):void
		{
			log += value;
			log += "\n";
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
			return outputDir + "\\" + show.name;
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