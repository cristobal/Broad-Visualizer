package com.bienvisto.UIComponents.node
{
	import com.bienvisto.elements.topology.Node;
	
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
		 * @private
		 */ 
		private var selectedNode:Node = null;
		
		
		/**
		 * Set the current selected node
		 */ 
		public function setSelectedNode(node:Node):void 
		{
			if (!node.selected) {
				if (selectedNode) {
					if ((selectedNode.id == node.id)) {
						visible = false;
						selectedNode = null;	
					}
				}
				return;
			}
			
			visible = node.selected;
			selectedNode = node;
			
			var value:String = String(node.id);
			var addressValue:String = "IPv4Address";
			if (node.nodeRole) {
				value = node.nodeRole.role;	
				addressValue = node.nodeRole.address;
			} 
			selectedNodeLabel.text = "Selected Node: " + value;
			nodeRoleAddress.text = addressValue;	
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
		}
	}
}