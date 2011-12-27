package view
{
	public interface IMainView
	{
		function setAppArguments(value:Array):void;
		function enableUI():void;
		function disableUI():void;

		function showLog():void;

		function get showName():String;
		function set showName(value:String):void;

		function get season():int;
		function set season(value:int):void;
	}
}