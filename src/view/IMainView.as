package view
{
	import core.mediaInfo.Show;

	public interface IMainView
	{
		function setAppArguments(value:Array):void;
		function enableUI():void;
		function disableUI():void;

		function showLog():void;

		function set editedShow(value:Show):void;
		function get showName():String;

		function get season():int;
	}
}