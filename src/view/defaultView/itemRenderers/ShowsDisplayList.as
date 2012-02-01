package view.defaultView.itemRenderers
{
	import core.mediaInfo.Show;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;

	public class ShowsDisplayList implements IList, IEventDispatcher
	{
		private var m_moveList:ArrayList = new ArrayList();
		private var m_list:ArrayList = new ArrayList();
		private var m_unfoldedList:ArrayList = new ArrayList();
		private var m_headers:Array;

		public function ShowsDisplayList()
		{
			m_moveList.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
		}


		public function get list():ArrayList
		{
			return m_list;
		}

		// used for binding
		public function set list(value:ArrayList):void
		{
			m_list = value;
		}

		public function set moveList(value:ArrayList):void
		{
			if (m_moveList)
			{
				m_moveList.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
			}
			m_moveList = value;
			m_moveList.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
			updateShowList();
		}

		public function get moveList():ArrayList
		{
			return m_moveList;
		}

		private function onCollectionChanged(ev:CollectionEvent):void
		{
			updateShowList();
		}

		private function updateShowList():void
		{
			var arr:Array = m_moveList.toArray();
			arr.sort(function(a:Object, b:Object, array:Array = null):int
			{
				if (a.hasOwnProperty("show") && b.hasOwnProperty("show"))
				{
					if (a.show.name>b.show.name)
						return 1;
					if (b.show.name>a.show.name)
						return -1;
					return 0;
				}
				return 0;
			});
			list.source = arr;
			addHeaders();
			updateListFolding();
		}

		private function addHeaders():void
		{
			var currShow:String = "";
			disposeHeaders();
			m_headers = new Array();
			var i:int;
			var o:Object;
			for (i=0; i<m_list.length; i++)
			{
				o = m_list.getItemAt(i);
				if (o.hasOwnProperty("show"))
				{
					var show:Show = o.show as Show;
					if (currShow!=show.name)
					{
						currShow = show.name;
						var header:HeaderItemData = new HeaderItemData();
						header.listItem = o;
						header.folded = true;
						header.addEventListener(Event.CHANGE, onHeaderChanged);
						m_headers.push(header);
					}
				}
			}
			for (i=0; i<m_headers.length; i++)
			{
				o = m_headers[i];
				var loc:int = m_list.getItemIndex(o.listItem);
				if (loc>-1)
				{
					list.addItemAt(o, loc);
				}
			}
			// reserve copy of unfolded list, so we can use it to reconstruct it whenever we need.
			m_unfoldedList.source = m_list.source.concat();
		}

		private function onHeaderChanged(ev:Event):void
		{
			updateListFolding();
		}

		private function updateListFolding():void
		{
			list.source = m_unfoldedList.source.concat();
			var o:Object;
			var toRemove:Array = new Array();
			var removeShowName:String = "";
			var i:int;
			for (i=0; i<m_list.length; i++)
			{
				o = m_list.getItemAt(i)
				if (o is HeaderItemData)
				{
					if (o.folded)
					{
						removeShowName = o.show.name;
					}
					else
					{
						removeShowName = "";
					}
				}
				else
				{
					if (removeShowName && o.show.name==removeShowName)
					{
						toRemove.push(i);
					}
				}
			}
			while(toRemove.length)
			{
				i = toRemove.pop();
				list.removeItemAt(i);
			}
		}

		private function disposeHeaders():void
		{
			if (m_headers)
			{
				while (m_headers.length)
				{
					var header:HeaderItemData = m_headers.pop();
					header.removeEventListener(Event.CHANGE, onHeaderChanged);
				}

			}

		}

		// ILIST implementation

		public function addItem(item:Object):void
		{
			m_list.addItem(item);
		}

		public function addItemAt(item:Object, index:int):void
		{
			m_list.addItemAt(item, index);
		}

		public function getItemAt(index:int, prefetch:int=0):Object
		{
			return m_list.getItemAt(index, prefetch);
		}

		public function getItemIndex(item:Object):int
		{
			return m_list.getItemIndex(item);
		}

		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
		{
			m_list.itemUpdated(item, property, oldValue, newValue);
		}

		public function get length():int
		{
			return m_list.length;
		}

		public function removeAll():void
		{
			m_moveList.removeAll();
		}

		public function removeItem(item:Object):Object
		{
			return m_moveList.removeItem(item);
		}

		public function removeItemAt(index:int):Object
		{
			var item:Object = m_list.getItemAt(index);
			var actualIndex:int = m_moveList.getItemIndex(item);
			if (actualIndex>=0)
			{
				m_moveList.removeItem(item);
			}
			return item;
		}

		public function setItemAt(item:Object, index:int):Object
		{
			return m_list.setItemAt(item, index);
		}

		public function toArray():Array
		{
			return m_list.toArray();
		}

		//IEVENTDISPATCHER


		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			m_list.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function dispatchEvent(event:Event):Boolean
		{

			return m_list.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return m_list.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			m_list.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type:String):Boolean
		{
			return m_list.willTrigger(type);
		}

	}
}