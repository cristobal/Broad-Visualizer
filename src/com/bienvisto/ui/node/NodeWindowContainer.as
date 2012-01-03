package com.bienvisto.ui.node
{
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.elements.buffer.Buffer;
	import com.bienvisto.elements.buffer.Buffers;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.Waypoint2D;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.elements.routing.RoutingTableEntry;
	import com.bienvisto.elements.sequences.SequencesRecv;
	import com.bienvisto.elements.sequences.SequencesSent;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.NodeView;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.containers.TabNavigator;
	import mx.core.FlexShape;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
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
		public var propertiesContent:NavigatorContent;
		
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
		public var metricsContent:NavigatorContent;
		
		/**
		 * @public
		 */ 
		public var routingContent:NavigatorContent;
		
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
		public var srTotalValue:Label;
		
		/**
		 * @private
		 */ 
		public var compassGroup:Group;
		
		/**
		 * @private
		 */ 
		private var compassShape:UIComponent;
		
		/**
		 * @private
		 */ 
		private var selectedNode:NodeSprite = null;
		
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
		public function set srTotal(value:String):void
		{
			srTotalValue.text = value;	
		}
		
		public function get srTotal():String
		{
			return srTotalValue.text;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint = 0;
		
		public function get time():uint
		{
			return _time;
		}
		
		public function setTime(value:uint):void
		{
			_time = value;
			invalidate();
		}
		
		private function invalidate():void
		{
			updateStats();
		}
		
		
		
		/**
		 * @private
		 */ 
		private var mobility:Mobility;
		
		/**
		 * Set mobility
		 * 
		 * @param mobility
		 */ 
		public function setMobility(mobility:Mobility):void
		{
			this.mobility = mobility;
		}
		
		/**
		 * @private
		 */ 
		private var buffers:Buffers;
		
		/**
		 * Set buffers
		 * 
		 * @param buffers
		 */ 
		public function setBuffers(buffers:Buffers):void
		{
			this.buffers = buffers;
		}
		
		/**
		 * @private
		 */ 
		private var transmissions:Transmissions;
		
		/**
		 * Set transmissions
		 * 
		 * @param transmissions
		 */ 
		public function setTransmissions(transmissions:Transmissions):void
		{
			this.transmissions = transmissions;
		}
		
		/**
		 * @private
		 */ 
		private var receptions:Receptions;
		
		/**
		 * Set receptions
		 * 
		 * @param receptions
		 */ 
		public function setReceptions(receptions:Receptions):void
		{
			this.receptions = receptions;
		}
		
		/**
		 * @private
		 */ 
		private var drops:Drops;
		
		/**
		 * Set drops
		 * 
		 * @param drops
		 */ 
		public function setDrops(drops:Drops):void
		{
			this.drops = drops;
		}
		
		/**
		 * @private
		 */ 
		private var sequencesRecv:SequencesRecv;
		
		/**
		 * Set sequencesRecv
		 * 
		 * @param sequencesRecv
		 */ 
		public function setSequencesRecv(sequencesRecv:SequencesRecv):void
		{
			this.sequencesRecv = sequencesRecv;
		}
		
		/**
		 * @private
		 */ 
		private var sequencesSent:SequencesSent;
		
		/**
		 * Set sequencesSent
		 * 
		 * @param sequencesSent
		 */ 
		public function setSequencesSent(sequencesSent:SequencesSent):void
		{
			this.sequencesSent = sequencesSent;
		}
		
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
			compassShape = new UIComponent();
			compassGroup.addElement(compassShape);
			
			propertiesContent.addEventListener(FlexEvent.SHOW, handleNavigatorContentShow);
			metricsContent.addEventListener(FlexEvent.SHOW, handleNavigatorContentShow);
			
			
			// draw compass
			drawCompass();
		}
		
		/**
		 * Bind events
		 */ 
		private function bind():void
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(CloseEvent.CLOSE, handleClose);
			
			// rout
		}
		
		
		/**
		 * Set node view
		 * 
		 * @param view
		 */ 
		public function setNodeView(view:NodeView):void
		{
			view.addEventListener(NodeSpriteEvent.SELECTED, handleNodeSpriteSelected);	
		}
		
		/**
		 * Set the current selected node
		 */ 
		protected function setSelectedNode(nodeSprite:NodeSprite):void 
		{
			
			if (selectedNode) {
				
				var flag:Boolean = selectedNode.node.id == nodeSprite.node.id;
				visible = !flag;
				selectedNode.selected = false;
				selectedNode 		  = null;
				if (flag) {	
					return;
				}
			}
			
			visible = nodeSprite.selected;
			selectedNode = nodeSprite;
			
			var node:Node = nodeSprite.node;
			var value:String = String(node.id);
			title = "Node  #" + String(node.id);
			
			var addressValue:String = "IPv4Address";
			role = node.role;
			ipv4Address = node.ipv4Address;
			macAddress = node.macAddress;
			
			updateStats();	
		}
		
		/**
		 * Update stats
		 */ 
		protected function updateStats():void
		{
			if (!selectedNode || !initialized) {
				return;
			}
			
			var node:Node = selectedNode.node;
			
			
			// Update properties
			if (propertiesContent.visible) {
				if (mobility) {
					var waypoint2D:Waypoint2D = mobility.findWaypoint(node, time);
					if (waypoint2D) {
						px = String(selectedNode.x);
						py = String(selectedNode.y);
						
						vx = String(waypoint2D.direction.x);
						vy = String(waypoint2D.direction.y);
						
						drawCompassDirection(waypoint2D);
						
					}
				}
			}
			
			// Update Metrics
			if (metricsContent.visible) {	
				var total:int;
				if (buffers) {
					var buffer:Buffer = buffers.findBuffer(node, time);
					if (buffer) {
						bufferSize = String(buffer.size);
					}
					else {
						bufferSize = "0";
					}
				}
				
				if (transmissions) {
					total = transmissions.sampleTotal(node, time);
					txTotal= String(total);
				}
				
				if (receptions) {
					total = receptions.sampleTotal(node, time)
					rxTotal = String(total);
				}
				
				if (drops) {
					total   = drops.sampleTotal(node, time);
					dxTotal = String(total);
				}
				
				if (sequencesSent) {
					total   = sequencesSent.sampleTotal(node, time);
					sxTotal = String(total);
				}
				if (sequencesRecv) {
					total   = sequencesRecv.sampleTotal(node, time);
					srTotal = String(total);
				}
			}
			
			// Update Routing
			if (routingContent.visible) {
			/*					var table:RoutingTableKeypoint; // = selectedNode.node.routingTable;
			if (table) {
			var value:String = "";
			for each(var entry:RoutingTableEntry in table.entries) {
			value += entry.toString() + "\n";
			}
			
			routingTableValue.text = value;
			}*/
			}
			
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Drawing
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Draw compass
		 */ 
		protected function drawCompass():void
		{
			var w:Number   = compassGroup.width;
			var h:Number   = compassGroup.height;
			var cx:Number  = w / 2;
			var cy:Number  = h / 2;
			var r:Number   = 33;
			var color:uint = 0x545454;
			
			compassGroup.graphics.lineStyle(1, color, 0.5);
			
			var dx:Number, dy:Number;
			var sx:int = 0, sy:int = 0;
			for (var angle:int = 45, max:int = 360; angle < max; angle += 90) {
				sx = angle >= 180 ? -1 : 1;
				sy = angle >= 90 && angle <= 270 ? -1 : 1;
				dx = cx + (sx * (r * Math.cos(45 * Math.PI / 180)));
				dy = cy + (sy * (r * Math.cos(45 * Math.PI / 180)));
				compassGroup.graphics.moveTo(cx, cy);
				compassGroup.graphics.lineTo(dx, dy);
				
				switch(angle - 45) {
					case 0: {
						sx = 0;
						sy = 1;
						break;
					}
					case 90: {
						sx = 1;
						sy = 0;
						break;
					}
					case 180: {
						sx = 0;
						sy = -1;
						break;
					}
					case 270: {
						sx = -1;
						sy = 0;
						break;
					}
				}
				
				dx = cx + (sx * r);
				dy = cy + (sy * r);
				compassGroup.graphics.moveTo(cx, cy);
				compassGroup.graphics.lineTo(dx, dy);
			}
			
			compassGroup.graphics.lineStyle(2, color);
			compassGroup.graphics.drawCircle(cx, cy, r);
			
			compassGroup.graphics.lineStyle(0);
			compassGroup.graphics.beginFill(color);
			compassGroup.graphics.drawCircle(cx, cy, 4);
			compassGroup.graphics.endFill();	
		}
		
		/**
		 * Draw compass direction
		 * 
		 * @param waypoint2D
		 */ 
		protected function drawCompassDirection(waypoint2D:Waypoint2D):void
		{			
			
			var position:Vector2D = waypoint2D.position;
			var direction:Vector2D = waypoint2D.direction;
			if (direction.x != 0 || direction.y != 0) {
				// we are moving…
				var w:Number   = compassGroup.width;
				var h:Number   = compassGroup.height;
				var cx:Number  = w / 2;
				var cy:Number  = h / 2;
				var r:Number   = 33;
				var color:uint = 0xFF6622;
				
				/*				
				var vx:Number = (direction.x / 1000) * time;
				var vy:Number = (direction.y / 1000) * time;
				var dx:Number = position.x + vx;
				var dy:Number = position.y + vy;
				*/
				
				var flag:Boolean = false;
				var sx:int = 0, sy:int = 0;
				var dx:Number = 0, dy:Number = 0;
				if (direction.x == 0) {
					sx = 0;
					sy = direction.y < 0 ? -1 : 1;
				}
				else if (direction.y == 0) {
					sx = direction.x < 0 ? -1 : 1;
					sy = 0;
				}
				else {
					sx = direction.x < 0 ? -1 : 1;
					sy = direction.y < 0 ? -1 : 1;
					flag = true;
				}
				
				if (flag) {
					dx = cx + (sx * (r * Math.cos(45 * Math.PI / 180)));
					dy = cy + (sy * (r * Math.cos(45 * Math.PI / 180)));
				}
				else {
					dx = cx + (sx * r);
					dy = cy + (sy * r);
				}
				
				compassShape.graphics.clear();
				compassShape.graphics.lineStyle(2, color);
				
				compassShape.graphics.moveTo(cx, cy);
				compassShape.graphics.lineTo(dx, dy);
			}
			else {
				compassShape.graphics.clear();
			}
			
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Events
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		protected function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			setup();
		}
		
		/**
		 * Handle close
		 * 
		 * @param event The close event
		 */ 
		protected function handleClose(event:CloseEvent):void 
		{
			visible = false;
			selectedNode.selected = false; // deselect current node
			selectedNode = null;
		}
		
		/**
		 * Handle node sprite selected
		 * 
		 * @param event
		 */ 
		protected function handleNodeSpriteSelected(event:NodeSpriteEvent):void
		{
			setSelectedNode(event.nodeSprite);
		}
		
		/**
		 * Handle navigator content show
		 * 
		 * @param event
		 */ 
		protected function handleNavigatorContentShow(event:FlexEvent):void
		{
			updateStats();
		}
	}
}