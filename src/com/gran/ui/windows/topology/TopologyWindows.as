package com.gran.ui.windows.topology
{
	import com.gran.core.network.node.Node;
	import com.gran.core.network.node.NodeContainer;
	import com.gran.elements.routing.Routing;
	import com.gran.elements.topology.Topology;
	import com.gran.ui.windows.BaseWindow;
	import com.gran.view.components.NodeView;
	import com.gran.view.events.NodeSpriteEvent;
	
	import flash.events.Event;
	
	import mx.events.CloseEvent;
	
	import spark.components.Group;
	import spark.events.TitleWindowBoundsEvent;
	
	/**
	 * TopologyWindows.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class TopologyWindows 
	{
		public function TopologyWindows(container:Group)
		{
			setup(container);
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
		
		/**
		 * @private
		 */ 
		private var nodeView:NodeView;
		
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		private function setup(container:Group):void
		{
			localTopologyWindow = new TopologyWindow();
			// localTopologyWindow.x -= (localTopologyWindow.width + 10);
			localTopologyWindow.setInitialPosition(40, localTopologyWindow.width + 20, "", "");
			localTopologyWindow.title = "Local Topology";
			localTopologyWindow.visible = false;
			localTopologyWindow.windowType = TopologyWindowContainer.WINDOW_TYPE_TOPOLOGY;
			container.addElement(localTopologyWindow);
			localTopologyWindow.addEventListener(BaseWindow.TOGGLE, handleTopologyWindowToggle);
	
			globalTopologyWindow = new TopologyWindow();
			globalTopologyWindow.setInitialPosition(40, 10, "", "");
			globalTopologyWindow.title = "Global Topology";
			globalTopologyWindow.visible = false;
			globalTopologyWindow.addEventListener(BaseWindow.TOGGLE, handleTopologyWindowToggle);
			container.addElement(globalTopologyWindow);
		}
		
		/**
		 * Update topology windows
		 */ 
		public function updateTopologyWindows():void
		{
			var from:Node = nodeView.selectedNodeSprite ? nodeView.selectedNodeSprite.node : null;
			var to:Node   = nodeView.selectedNodeSprite2 ? nodeView.selectedNodeSprite2.node : null;
			if (localTopologyWindow.visible && !localTopologyWindow.userDefined) {
				localTopologyWindow.setSelectedNodes(from, to);
			}
			
			if (globalTopologyWindow.visible && !globalTopologyWindow.userDefined) {
				globalTopologyWindow.setSelectedNodes(from, to);
			}
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
		
		/**
		 * Set node view
		 * 
		 * @param view
		 */ 
		public function setNodeView(view:NodeView):void
		{
			nodeView = view;
			nodeView.addEventListener(NodeSpriteEvent.SELECTED, handleNodeSpriteSelected);	
		}
		
		/**
		 * Reset
		 */ 
		public function reset():void
		{
			localTopologyWindow.reset();
			localTopologyWindow.visible = false;
			
			globalTopologyWindow.reset();
			globalTopologyWindow.visible = false;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Events
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle node sprite selected
		 * 
		 * @param event
		 */ 
		private function handleNodeSpriteSelected(event:NodeSpriteEvent):void
		{
			updateTopologyWindows();
		}
		
		/**
		 * Handle topology window toggle
		 * 
		 * @param event
		 */ 
		private function handleTopologyWindowToggle(event:Event):void
		{
			updateTopologyWindows();
		}
		
		
	}
}