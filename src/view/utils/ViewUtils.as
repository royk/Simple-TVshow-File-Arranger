package view.utils
{
	import flash.events.Event;

	import mx.controls.TextInput;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;

	import spark.components.CheckBox;
	import spark.components.RichEditableText;
	import spark.components.TextArea;
	import spark.events.TextOperationEvent;

	/**
	 * Contains all ugly hacks required for the desired behavior of the app views.
	 */
	public class ViewUtils
	{
		/**
		 * Causes all components under root to rebind by pretending they're changed
		 * @root the base DisplayObject that is the direct or indirect parent of all the components you wish to rebind
		 */
		public function triggerComponentBindings(root:UIComponent):void
		{
			// Recursively goes over all children
			if (root)
			{
				if (root is RichEditableText)
				{
					root.dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE));
				}
				else if (root is TextInput)
				{
					root.dispatchEvent(new Event(Event.CHANGE));
				}
				else if (root is CheckBox)
				{
					var ev:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
					ev.property = "selected";
					root.dispatchEvent(ev);
				}
				for (var i:int=0; i<root.numChildren; i++)
				{
					triggerComponentBindings(root.getChildAt(i) as UIComponent);
				}
			}
		}

		/**
		 * Scrolls a text area to the bottom, so the most up to date text is visible
		 *
		 */
		public function scrollToBottom(field:TextArea):void
		{
			if (field.hasEventListener(Event.ENTER_FRAME)==false)
			{
				field.addEventListener(Event.ENTER_FRAME, updateScroll, false, 0, true);
			}
		}

		private function updateScroll(ev:Event):void
		{
			var field:TextArea = ev.target as TextArea;
			if (field)
			{
				field.removeEventListener(Event.ENTER_FRAME, updateScroll);
				field.scrollToRange(int.MAX_VALUE);
//				field.scroller.verticalScrollBar.value = field.scroller.verticalScrollBar.maximum + 10;
			}
		}
	}
}