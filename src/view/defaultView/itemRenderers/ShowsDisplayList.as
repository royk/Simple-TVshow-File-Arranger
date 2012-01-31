package view.defaultView.itemRenderers
{
	import core.mediaInfo.Show;

	import flash.events.Event;

	import mx.collections.ArrayList;

	public class ShowsDisplayList
	{
		private var m_list:ArrayList = new ArrayList();
		private var m_unfoldedList:ArrayList = new ArrayList();
		private var m_headers:Array;

		public function ShowsDisplayList()
		{
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
			var arr:Array = value.toArray();
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
	}
}