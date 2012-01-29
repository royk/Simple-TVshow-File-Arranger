package view.defaultView.components
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import mx.collections.ArrayCollection;

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
				selectAllItems();
			}
			else
			if (event.keyCode==Keyboard.DELETE)
			{
				removeSelectedItems();
			}
		}

		private function selectAllItems():void
		{
			var selItems:Vector.<int> = new Vector.<int>();
			for (var i:int=0; i<dataProvider.length; i++)
			{
				selItems.push(i);
			}
			selectedIndices = selItems.concat();
		}

		public function removeSelectedItems():void
		{
			for each (var o:Object in selectedItems)
			{
				var index:int = (dataProvider as ArrayCollection).getItemIndex(o);
				(dataProvider as ArrayCollection).removeItemAt(index);
			}
			dataGroup.invalidateDisplayList();
		}


	}
}