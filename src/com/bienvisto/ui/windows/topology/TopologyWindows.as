package com.bienvisto.ui.windows.topology
{
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.topology.Topology;
	
	import mx.events.CloseEvent;
	
	import spark.components.Group;
	
	/**
	 * TopologyWindows.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class TopologyWindows extends Group
	{
		public function TopologyWindows()
		{
			super();
			setup();
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */		
		public var localTopologyWindow:TopologyWindow;
		
		/**
		 * @private
		 */ 
		public var globalTopologyWindow:TopologyWindow;
		
		
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			localTopologyWindow = new TopologyWindow();
			localTopologyWindow.x -= (localTopologyWindow.width + 10);
			localTopologyWindow.title = "Local Topology";
			localTopologyWindow.visible = false;
			localTopologyWindow.windowType = TopologyWindowContainer.WINDOW_TYPE_TOPOLOGY;
			addElement(localTopologyWindow);
			
			
			globalTopologyWindow = new TopologyWindow();
			globalTopologyWindow.title = "Global Topology";
			globalTopologyWindow.visible = false;
			addElement(globalTopologyWindow);
		}
		
		/**
		 * Set node container
		 * 
		 * @param nodeContainer
		 */ 
		public function setNodeContainer(nodeContainer:NodeContainer):void
		{
			localTopologyWindow.setNodeContainer(nodeContainer);
			globalTopologyWindow.setNodeContainer(nodeContainer);
		}
		
		/**
		 * Set time
		 * 
		 * @param time
		 */ 
		public function setTime(time:uint):void
		{
			localTopologyWindow.setTime(time);
			globalTopologyWindow.setTime(time);
		}
		
		/**
		 * Set routing
		 * 
		 * @param routing
		 */		
		public function setRouting(routing:Routing):void
		{
			globalTopologyWindow.setRouting(routing);
		}
		
		/**
		 * Set topology
		 * 
		 * @param topology
		 */ 
		public function setTopology(topology:Topology):void
		{
			localTopologyWindow.setTopology(topology);
		}
		
	}
}