package com.poisontaffy.libs.flex4
{
	import flash.events.Event;

	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;

	import spark.components.CheckBox;
	import spark.components.RichEditableText;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;

	/**
	 * Utils and hacks for Flex 4 components
	 * @author Roy Klein
	 *
	 */
	public class PTFlex4Utils
	{
		/**
		 * Causes all components under root to rebind by pretending they're changed
		 * Right now works only with Spark components.
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
		 * Scrolls a Spark text area to the bottom, so the most up to date text is visible
		 * @field the S:TextArea to scroll to the bottom of
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
			}
		}
	}
}