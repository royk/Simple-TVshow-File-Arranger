package core.fileIO
{
	public interface IFileIOObserver
	{
		function moveSuccess():void;
		function moveError(failedFile:String, reason:String):void;
	}
}