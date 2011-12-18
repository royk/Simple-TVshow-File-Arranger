package core.db
{
	public interface IShowsDB
	{
		function init		()				:void;
		function addShow	(name:String)	:void;
		function getShows	()				:Array;
		function get ready	()				:Boolean;

	}
}