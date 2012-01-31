package view.defaultView.itemRenderers
{
	import core.mediaInfo.Show;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class HeaderItemData extends EventDispatcher
	{
		private var m_folded	:Boolean = false;
		public  var show		:Show;
		private var m_listItem	:Object;


		public function get folded():Boolean
		{
			return m_folded;
		}

		public function set folded(value:Boolean):void
		{
			m_folded = value;
			dispatchEvent(new Event(Event.CHANGE));
		}

		public function get listItem():Object
		{
			return m_listItem;
		}

		public function set listItem(value:Object):void
		{
			m_listItem = value;
			show = m_listItem.show;
			dispatchEvent(new Event(Event.CHANGE));
		}

	}
}