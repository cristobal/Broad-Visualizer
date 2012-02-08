package com.bienvisto.ui.windows.topology
{
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.core.network.node.NodeContainer;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.topology.Topology;
	import com.bienvisto.view.components.NodeView;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import mx.events.CloseEvent;
	
	import spark.components.Group;
	
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
			
			
			globalTopologyWindow = new TopologyWindow();
			globalTopologyWindow.setInitialPosition(40, 10, "", "");
			globalTopologyWindow.title = "Global Topology";
			globalTopologyWindow.visible = false;
			container.addElement(globalTopologyWindow);
		}
		
		/**
		 * Update topology windows
		 */ 
		private function updateTopologyWindows():void
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
		
		
	}
}