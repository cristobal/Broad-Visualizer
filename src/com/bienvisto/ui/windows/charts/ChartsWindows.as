package com.bienvisto.ui.windows.charts
{
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import mx.events.CloseEvent;
	
	import spark.components.Group;
	
	/**
	 * ChartsWindows.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class ChartsWindows
	{
		public function ChartsWindows(container:Group)
		{
			this.container = container;
		}
		
		/**
		 * @private
		 */ 
		private var container:Group;
		
		/**
		 * @private
		 */ 
		private var clampTime:uint = 1000; // sample every 1000seconds
		
		/**
		 * @private
		 */ 
		private var windows:Vector.<ChartsWindow> = new Vector.<ChartsWindow>();
		
		/**
		 * @private
		 */ 
		private var dataProviders:Vector.<AggregateDataProvider> = new Vector.<AggregateDataProvider>();
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var _duration:uint;
		
		/**
		 * @readonly duration
		 */ 
		public function get duration():uint
		{
			return _duration;
		}
		
		/**
		 * @private
		 */ 
		public function setDuration(duration:uint):void
		{
			_duration = duration;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint;
		
		/**
		 * @readonly time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		/**
		 * @private
		 */ 
		public function setTime(time:uint):void
		{
			_time = time;
			for (var i:int = 0, l:int = windows.length; i < l; i++) {
				windows[i].setTime(time);
			}
		}
		
		/**
		 * @private
		 */ 
		private var _nodeContainer:NodeContainer;
		
		/**
		 * @readwrite nodes
		 */ 
		public function get nodeContainer():NodeContainer
		{
			return _nodeContainer;	
		}
		
		public function setNodeContainer(value:NodeContainer):void
		{
			_nodeContainer = value;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Add data provider
		 * 
		 * @param dataProvider
		 */ 
		public function addDataProvider(dataProvider:AggregateDataProvider):void
		{
			dataProviders.push(dataProvider);
		}
		
		/**
		 * Add
		 */ 
		public function add():ChartsWindow
		{
			var window:ChartsWindow = new ChartsWindow();
			window.duration = duration;
			window.setDataProviders(dataProviders);
			window.setNodes(nodeContainer.nodes);
			window.x = 10;
			window.y = 40;
			window.addEventListener(CloseEvent.CLOSE, handleChartsWindowClose);
			container.addElement(window);
			windows.push(window);
			
			return window;
		}
		
		/**
		 * Remove
		 * 
		 * @param window
		 */ 
		public function remove(window:ChartsWindow):void
		{
			var item:ChartsWindow;
			for (var i:int = windows.length; i--;){ 
				item = windows[i];	
				if (item == window) {
					windows.splice(i, 1);
					container.removeElement(window);
					window = null;
					break;
				}
			}
		}
		
		/**
		 * Handle charts window close
		 * 
		 * @param event
		 */ 
		private function handleChartsWindowClose(event:CloseEvent):void
		{
			var window:ChartsWindow = ChartsWindow(event.target);
			remove(window);
		}
	}
}