package core.settings
{
	import flash.events.EventDispatcher;

	[Bindable]
	public class Settings extends EventDispatcher
	{
		public var inputDir			:String = "";
		public var outputDir		:String = "";
		public var xbmcDB			:String = "";
		public var recursiveScan	:Boolean = false;
		public var autoRun			:Boolean = false;
		public var ignoreNewShows	:Boolean = false;
	}
}