package view.defaultView.skin
{
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.states.State;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	
	[SkinState("normal")]
	[SkinState("disabled")]
	[SkinState("expanded")]
	
	public class CollapsibleGroup extends SkinnableContainer
	{
		[SkinPart(required="true")]
		public var label:Label;
		
		[SkinPart(required="true")]
		public var clickContainer:BorderContainer;
		
		private var m_collapsedText:String;
		private var m_expandedText:String;
		
		public function CollapsibleGroup()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			states = [
						new State({name:"normal"}), 
						new State({name:"disabled"}), 
						new State({name:"expanded"})
					];
			currentState = "normal";
		}
		
		private function onCreationComplete(event:FlexEvent):void
		{
			clickContainer.addEventListener(MouseEvent.CLICK, onClick);
			updateText();
		}
		
		private function updateText():void
		{
			if (label)
			{
				if (currentState=="normal")
				{
					label.text = m_collapsedText;
				}
				else
				{
					label.text = m_expandedText;
				}
			}
			
		}
		
		private function onClick(event:MouseEvent):void
		{
			if (currentState=="normal")
			{
				currentState = "expanded";
			}
			else
			{
				currentState = "normal";
			}
			invalidateSkinState();
			updateText();
		}
		
		[Bindable]
		public function set collapsedText(value:String):void
		{
			m_collapsedText = value;
		}
		
		public function get collapsedText():String
		{
			return m_collapsedText;
		}
		
		[Bindable]
		public function set expandedText(value:String):void
		{
			m_expandedText = value;
		}
		
		public function get expandedText():String
		{
			return m_expandedText;
		}
		
		override protected function getCurrentSkinState():String
		{
			return currentState;
		}
		
	}
}