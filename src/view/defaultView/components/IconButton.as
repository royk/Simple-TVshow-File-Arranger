package view.defaultView.components
{
	import mx.events.FlexEvent;

	import spark.components.Button;
	import spark.primitives.BitmapImage;

	public class IconButton extends Button
	{
		[SkinPart(required="true")]
		public var iconSymbol:BitmapImage;

		public var m_icon:String;

		public function IconButton()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}

		public function set icon(value:String):void
		{
			m_icon = value;
			if (iconSymbol)
			{
				iconSymbol.source = value;
			}
		}

		private function onCreationComplete(event:FlexEvent):void
		{
			icon = m_icon;
		}
	}
}