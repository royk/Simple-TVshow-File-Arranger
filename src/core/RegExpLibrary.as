package core
{
	public class RegExpLibrary
	{
		// TV
		static public const TV_SHOW_NAME:RegExp 	= /(?:s\d{1,2}|_(?:\d|s\d{2,})|\d{3,4}|\.(?:\d|s\d{2,})).*/i;
		static public const TV_EPISODE_INFO:RegExp 	= /(?:\x2E|_)?(s?\d{1,2})(?:x?|_?)(e?\d{1,2})/i;

		static public const TV_EPISODE_NUMBER:RegExp 	= /e?0?(\d+)/i;
		static public const TV_SEASON_NUMBER:RegExp 	= /s?0?(\d+)/i;

		// General Purpose
		static public const NAME_SEPARATOR:RegExp	= /\s*[-]\s*$/;
		static public const WHITE_SPACE_TRIM:RegExp	= /[ \t]+$/gi;
	}
}