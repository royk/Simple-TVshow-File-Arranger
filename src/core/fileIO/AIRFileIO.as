package core.fileIO
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;

	public class AIRFileIO
	{
		private var m_observer:IFileIOObserver;

		public function AIRFileIO()
		{
		}

		public function move(filePath:String, targetDirectoryPath:String, observer:IFileIOObserver):void
		{
			m_observer = observer;
			var source:File = new File(filePath);
			if (source && source.exists && source.isDirectory==false)
			{
				var target:File = new File(targetDirectoryPath);
				if (target && target.exists==false && target.isDirectory==false)
				{
					moveFile(source, target);
				}
				else
				{
					m_observer.moveError(filePath, "Invalid target location!");
				}
			}
			else
			{
				m_observer.moveError(filePath, "Invalid source file!");
			}
		}

		private function moveFile(source:File, target:File):void
		{
			source.addEventListener(Event.COMPLETE, onMoveComplete);
			source.addEventListener(IOErrorEvent.IO_ERROR, onMoveError);
			source.moveToAsync(target);
		}

		private function onMoveComplete(ev:Event):void
		{
			m_observer.moveSuccess();
		}

		private function onMoveError(ev:IOErrorEvent):void
		{
			m_observer.moveError((ev.target as File).nativePath, ev.text);
		}
	}
}