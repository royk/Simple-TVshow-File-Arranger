package core.db
{
	public interface IShowsDB
	{

		function addShow	(name:String)	:void;
		function getShows	()				:Array;

	}
}