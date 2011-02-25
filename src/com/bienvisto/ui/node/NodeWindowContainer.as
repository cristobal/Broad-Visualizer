package com.bienvisto.ui.node
{
	import com.bienvisto.elements.topology.TopologyNode;
	
	import flash.events.Event;
	
	import mx.events.CloseEvent;
	
	import spark.components.Label;
	import spark.components.TitleWindow;
	
	/**
	 * NodeWindowContainer
	 * 	This is the code behind controller class for the NodeWindow.mxml
	 * 
	 * @author Cristobal Dabed
	 * @version {{VERSION_NUMBER}}
	 */ 
	public class NodeWindowContainer extends TitleWindow
	{
		public function NodeWindowContainer()
		{
			super();
			
			addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
		/**
		 * @public
		 */ 
		public var selectedNodeLabel:Label;
		
		/**
		 * @public
		 */ 
		public var nodeRoleAddress:Label;
		
		/**
		 * @public
		 */ 
		public var bufferSize:Label;
		
		/**
		 * @public
		 */ 
		public var transmissionTotal:Label;

		/**
		 * @public
		 */ 
		public var receptionsTotal:Label;
		
		/**
		 * @public
		 */ 
		public var dropsTotal:Label;

		
		/**
		 * @private
		 */ 
		private var selectedNode:TopologyNode = null;
		
		
		/**
		 * Set the current selected node
		 */ 
		public function setSelectedNode(topologyNode:TopologyNode):void 
		{
			if (!topologyNode.selected) {
				if (selectedNode) {
					if ((selectedNode.id == topologyNode.id)) {
						visible = false;
						selectedNode = null;	
					}
				}
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
				return;
			}
			
			visible = topologyNode.selected;
			selectedNode = topologyNode;
			
			var value:String = String(topologyNode.id);
			var addressValue:String = "IPv4Address";
			if (topologyNode.node) {
				value = topologyNode.node.role;	
				addressValue = topologyNode.node.address;
			} 
			selectedNodeLabel.text = "Selected Node: " + value;
			nodeRoleAddress.text = addressValue;	
			
			updateStats();
			addEventListener(Event.EXIT_FRAME, handleEnterFrame, false, 0, true);
		}
		
		/**
		 * Update stats
		 */ 
		private function updateStats():void
		{
			if (selectedNode) {
				bufferSize.text = String(selectedNode.node.bufferSize);
				transmissionTotal.text = String(selectedNode.node.transmissionsTotal);
				receptionsTotal.text = String(selectedNode.node.receptionsTotal);
				dropsTotal.text = String(selectedNode.node.dropsTotal);
			}
		}
		
		
		/**
		 * Handle close
		 * 
		 * @param event The close event
		 */ 
		private function handleClose(event:CloseEvent):void 
		{
			// NOTE: Should current node be deselected ?
			visible = false;
			selectedNode = null;
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
		}
		
		/**
		 * Handle enter frame
		 * 
		 * @param event 
		 */ 
		private function handleEnterFrame(event:Event):void
		{
			updateStats();
		}
	}
}