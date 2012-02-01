package com.poisontaffy.libs.utils.files
{
	public class FileNameUtils
	{
		static public function santizePath(value:String):String
		{
			// remove trailing slash
			value = value.replace(/\\$/, "");

			return value;
		}
	}
}