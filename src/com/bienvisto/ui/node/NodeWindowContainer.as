package com.bienvisto.ui.node
{
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.routing.RoutingTable;
	import com.bienvisto.elements.routing.RoutingTableEntry;
	import com.bienvisto.elements.topology.TopologyNode;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.RichText;
	import spark.components.TitleWindow;
	
	// TODO: Add video sequences sent forward total 
	// TOOD: Add video sequences drop total 
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
			bind();	
		}
		
		/**
		 * @public
		 */ 
		public var properties:NavigatorContent;
		
		/**
		 * @public
		 */ 
		public var roleValue:Label;

		/**
		 * @public
		 */ 
		public var ipv4AddressValue:Label;
		
		/**
		 * @public
		 */ 
		public var macAddressValue:Label;
		
		/**
		 * @public
		 */ 
		public var pxValue:Label;
		
		/**
		 * @public
		 */ 
		public var pyValue:Label;
		
		/**
		 * @public
		 */ 
		public var vxValue:Label;
		
		/**
		 * @public
		 */ 
		public var vyValue:Label;
		
		/**
		 * @public
		 */ 
		public var routingTableValue:RichText; 
		
		/**
		 * @public
		 */ 
		public var metrics:NavigatorContent;
		
		/**
		 * @public
		 */ 
		public var bufferSizeValue:Label;
		
		/**
		 * @public
		 */ 
		public var txTotalValue:Label;

		/**
		 * @public
		 */ 
		public var rxTotalValue:Label;
		
		/**
		 * @public
		 */ 
		public var dxTotalValue:Label;

		/**
		 * @public
		 */ 
		public var sxTotalValue:Label;
		
		/**
		 * @public
		 */ 
		public var sdTotalValue:Label;
		
		/**
		 * @private
		 */ 
		private var selectedNode:TopologyNode = null;
		
		/**
		 * @readwrite role
		 */ 
		public function set role(value:String):void
		{
			roleValue.text = value;
		}
		
		public function get role():String
		{
			return roleValue.text;
		}
		
		/**
		 * @readwrite ipv4address
		 */ 
		public function set ipv4Address(value:String):void
		{
			ipv4AddressValue.text = value;
		}		
		
		public function get ipv4Address():String 
		{
			return ipv4AddressValue.text;
		}
		
		/**
		 * @readwrite macAddress
		 */ 
		public function set macAddress(value:String):void
		{
			macAddressValue.text = value;	
		}
		
		public function get macAddress():String
		{
			return macAddressValue.text;
		}
		
		/**
		 * @readwrite px
		 */ 
		public function set px(value:String):void
		{
			pxValue.text = value;	
		}
		
		public function get px():String
		{
			return pxValue.text;
		}
		
		/**
		 * @readwrite py
		 */ 
		public function set py(value:String):void
		{
			pyValue.text = value;	
		}
		
		public function get py():String
		{
			return pyValue.text;
		}
		
		/**
		 * @readwrite vx
		 */ 
		public function set vx(value:String):void
		{
			vxValue.text = value;	
		}
		
		public function get vx():String
		{
			return vxValue.text;
		}
		
		/**
		 * @readwrite vx
		 */ 
		public function set vy(value:String):void
		{
			vyValue.text = value;	
		}
		
		public function get vy():String
		{
			return vyValue.text;
		}
		
		/**
		 * @readwrite buffer size
		 */ 
		public function set bufferSize(value:String):void
		{
			bufferSizeValue.text = value;	
		}
		
		public function get bufferSize():String
		{
			return bufferSizeValue.text;
		}
		
		/**
		 * @readwrite transmissions total
		 */ 
		public function set txTotal(value:String):void
		{
			txTotalValue.text = value;	
		}
		
		public function get txTotal():String
		{
			return txTotalValue.text;
		}
		
		
		/**
		 * @readwrite receptions total
		 */ 
		public function set rxTotal(value:String):void
		{
			rxTotalValue.text = value;	
		}
		
		public function get tx():String
		{
			return rxTotalValue.text;
		}
		
		/**
		 * @readwrite drops total
		 */ 
		public function set dxTotal(value:String):void
		{
			dxTotalValue.text = value;	
		}
		
		public function get dxTotal():String
		{
			return dxTotalValue.text;
		}
		
		
		/**
		 * @readwrite sequences sent total
		 */ 
		public function set sxTotal(value:String):void
		{
			sxTotalValue.text = value;	
		}
		
		public function get sxTotal():String
		{
			return sxTotalValue.text;
		}
		
		/**
		 * @readwrite sequences drop total
		 */ 
		public function set sdTotal(value:String):void
		{
			sdTotalValue.text = value;	
		}
		
		public function get sdTotal():String
		{
			return sdTotalValue.text;
		}
		
		/**
		 * Bind events
		 */ 
		private function bind():void
		{
			addEventListener(FlexEvent.SHOW, handleShow);
			addEventListener(FlexEvent.HIDE, handleHide);
			addEventListener(CloseEvent.CLOSE, handleClose);
			
		}
		
		
		/**
		 * Set the current selected node
		 */ 
		public function setSelectedNode(topologyNode:TopologyNode):void 
		{
			
			if (selectedNode) {
				
				var flag:Boolean = selectedNode.id == topologyNode.id;
				visible = !flag;
				selectedNode.selected = false;
				selectedNode 		  = null;
				if (flag) {	
					return;
				}
			}
			
			visible = topologyNode.selected;
			selectedNode = topologyNode;
			
			var value:String = String(topologyNode.id);
			title = "Node  #" + String(topologyNode.id);

			var addressValue:String = "IPv4Address";
			if (topologyNode.node) {
				role = topologyNode.node.role;
				ipv4Address = topologyNode.node.ipv4Address;
				macAddress = topologyNode.node.macAddress;
			}
			updateStats();	
		}
		
		/**
		 * Update stats
		 */ 
		private function updateStats():void
		{
			if (selectedNode) {
				if (properties.visible) {
					
					
					px = String(selectedNode.position.x);
					py = String(selectedNode.position.y);
					
					vx = String(selectedNode.direction.x);
					vy = String(selectedNode.direction.y);
					
					var table:RoutingTable = selectedNode.node.routingTable;
					if (table) {
						var value:String = "";
						for each(var entry:RoutingTableEntry in table.entries) {
							value += entry.toString() + "\n";
						}
						
						routingTableValue.text = value;
					}
				}
				else if (metrics.visible) {
					bufferSize = String(selectedNode.node.bufferSize);
					txTotal = String(selectedNode.node.transmissionsTotal);
					rxTotal = String(selectedNode.node.receptionsTotal);
					dxTotal = String(selectedNode.node.dropsTotal);
					// sxTotal = String(selectedNode.node.sequencesSentTotal);
					// sdTotal = String(selectedNode.node.sequencesDropTotal);
				}
			}
		}
		
		/**
		 * Handle show
		 * 
		 * @param event
		 */ 
		private function handleShow(event:FlexEvent):void
		{
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.EXIT_FRAME, handleEnterFrame, false, 0, true);	
			}
		}
		
		/**
		 * Handle hide
		 * 
		 * @param event
		 */ 
		private function handleHide(event:FlexEvent):void
		{
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
		}
		
		/**
		 * Handle close
		 * 
		 * @param event The close event
		 */ 
		private function handleClose(event:CloseEvent):void 
		{
			visible = false;
			selectedNode.selected = false; // deselect current node
			selectedNode = null;
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