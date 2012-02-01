package core.settings
{
	import com.poisontaffy.libs.utils.files.FileNameUtils;

	import flash.events.EventDispatcher;

	[Bindable]
	public class Settings extends EventDispatcher
	{
		private var m_inputDir			:String = "";
		private var m_outputDir		:String = "";
		public var xbmcDB			:String = "";
		public var recursiveScan	:Boolean = false;
		public var autoRun			:Boolean = false;
		public var ignoreNewShows	:Boolean = false;


		public function get inputDir():String
		{
			return m_inputDir;
		}

		public function set inputDir(value:String):void
		{
			value = FileNameUtils.santizePath(value);
			m_inputDir = value;
		}

		public function get outputDir():String
		{
			return m_outputDir;
		}

		public function set outputDir(value:String):void
		{
			value = FileNameUtils.santizePath(value);
			m_outputDir = value;
		}

	}
}