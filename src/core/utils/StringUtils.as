package core.utils
{
	public class StringUtils
	{
		static public function globalReplace(text:String, originalText:String, newText:String):String
		{
			var i:int=0;
			while (text.indexOf(originalText)>0)
			{
				text = text.replace(originalText, newText);
				if (i++>=100)
				{
					throw new Error("Infinite loop!");
					return;
				}
			}
			return text;
		}

		static public function capitalizeWords(text:String):String
		{
			var words	:Array;
			var word	:String;
			words = text.split(" ");
			for (var i:int=0; i<words.length; i++)
			{
				word 		= words[i];
				words[i] 	= word.charAt(0).toUpperCase() + word.substr(1);
			}
			return words.join(" ");
		}
	}
}