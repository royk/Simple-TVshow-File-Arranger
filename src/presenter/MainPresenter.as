package presenter
{
	import core.MediaArrangerCore;
	import core.mediaInfo.Show;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;

	import mx.events.ItemClickEvent;

	import view.IMainView;

	public class MainPresenter extends EventDispatcher
	{
		private var tv_location:String = "z:";
		private var movie_location:String = "y:";
		private var i:int = 0;
		private var m_core:MediaArrangerCore = new MediaArrangerCore();
		private var m_view:IMainView;
		private var m_previousShow:Show;
		private var m_currentShow:Show;

		private var m_file:File;
		private var m_inputDir:String = "C:\\mediamovertest";
		private var m_mediaName:String;
		private var m_season:String;
		private var m_episode:String;
		private var m_targetFolder:String;
		private var m_currentFileName:String;
		private var m_copyStatus:String;

		private var m_movementStack:Array = new Array();
		private var m_copyInProgress:Boolean = false;

		public function MainPresenter(view:IMainView)
		{
			m_view = view;
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
				currentFileName = m_file.name;
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
		public function get episode():String
		{
			return m_episode;
		}

		public function set episode(value:String):void
		{
			m_episode = value;
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

		public function scanNextFile(movePreviousFile:Boolean=true):void
		{
			if (movePreviousFile)
			{
				move();
			}
			m_previousShow = m_currentShow;
			m_currentShow = null;
			var dir:File = new File(inputDir);
			var found:Boolean = false;
			var startIndex:int = i;
			while(found==false)
			{
				if (dir.exists && dir.isDirectory)
				{
					var files:Array = dir.getDirectoryListing();
					files.sortOn("name");
					if (files.length==i)
					{
						i = 0;
						if (i==startIndex)
						{
							break;
						}
					}
					file = files[i] as File;
					if (file && file.isDirectory==false)
					{
						found = true;
						process();
					}
					i++;
				}
			}

		}

		private function move():void
		{
			if (file)
			{
				var moveFile:File = new File(file.nativePath);
				var newLocation:File = new File(targetFolder);
				if (m_copyInProgress==false)
				{
					moveFiles(moveFile, newLocation);
				}
				else
				{
					m_movementStack.push({file:moveFile, location:newLocation});
				}
			}
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
			if (m_movementStack.length)
			{
				var data:Object = m_movementStack.shift();
				moveFiles(data.file, data.location);
			}
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
			if (m_movementStack.length)
			{
				var data:Object = m_movementStack.shift();
				moveFiles(data.file, data.location);
			}
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
			episode 		= m_currentShow.episode.toString();
			mediaName 		= m_currentShow.name;
			updateTargetName();
			m_view.setMediaType("tv");
		}

		private function updateTargetName():void
		{
			targetFolder 	= tv_location + "\\" + m_currentShow.name + "\\" + "s"+m_currentShow.season + "\\" + m_currentShow.fileName;
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