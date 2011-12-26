package view
{
	public interface IMainView
	{
		function setAppArguments(value:Array):void;
		function enableUI():void;
		function disableUI():void;

		function showLog():void;
	}
}