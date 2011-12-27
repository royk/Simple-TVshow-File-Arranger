package view.defaultView.components
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import spark.components.List;

	public class List2 extends List
	{
		public function List2()
		{
			super();
		}

		override protected function keyDownHandler(event:KeyboardEvent) : void
		{
			super.keyDownHandler( event );
			if (event.ctrlKey && event.keyCode==Keyboard.A)
			{
				selectAllItems(length);
			}
		}

		private function selectAllItems(length:int):void
		{
			var selItems:Vector.<int> = new Vector.<int>();
			for (var i:int=0; i<dataProvider.length; i++)
			{
				selItems.push(i);
			}
			selectedIndices = selItems.concat();
		}


	}
}