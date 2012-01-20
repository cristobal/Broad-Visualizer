package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.routing.RoutingTable;
	import com.bienvisto.elements.routing.RoutingTableEntry;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	// TODO: Optimize drawing to use one shape and draw only paths needed…
	/**
	 * NodeRoutingDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeRoutingDrawingManager extends NodeDrawingManager
	{
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		public function NodeRoutingDrawingManager(routing:Routing, view:Sprite)
		{
			super("Routing");
			this.routing = routing;
			this.view = view;
			
			view.addChild(routesShape);
			_selectedDrawingManager.addEventListener(Event.CHANGE, handleSelectedDrawingManagerChange);
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var routing:Routing;
		
		/**
		 * @private
		 */
		private var view:Sprite;
		
		/**
		 * @private
		 */ 
		private var routesShape:Shape = new Shape();
		
		/**
		 * @private
		 */ 
		private var lastTime:uint = 0;
		
		/**
		 * @private
		 */
		private var drawState:String = "all";
		
		/**
		 * @private
		 */ 
		private var _selectedDrawingManager:NodeRoutingSelectedDrawingManager = new NodeRoutingSelectedDrawingManager();
		
		
		/**
		 * @readonly
		 */ 
		public function get selectedDrawingManager():NodeRoutingSelectedDrawingManager
		{
			return _selectedDrawingManager;
		}
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		/**
		 * Invalidate
		 */ 
		override protected function invalidate():void
		{
			invalidateState();
			super.invalidate();
		}
		
		/**
		 * Invalidate state
		 */ 
		private function invalidateState():void
		{
			routesShape.visible = enabled || selectedDrawingManager.enabled;
			drawState = "none";
			if (routesShape.visible) {
				if (!enabled && selectedDrawingManager.enabled) {
					drawState = "selected";
				}
				else if (enabled && !selectedDrawingManager.enabled) {
					drawState = "paths";
				}
				else {
					drawState = "all";
				}
			}
		}
		
		/**
		 * Update
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			if ((lastTime != time) && (drawState != "none")) {
				draw(time, nodeSprites);
				
				lastTime = time;
			}
		}
		
		/**
		 * Draw
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		private function draw(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			var paths:Dictionary = new Dictionary();
			var spritesCache:Dictionary = new Dictionary();
			
			var nodeSprite:NodeSprite, table:RoutingTable, entry:RoutingTableEntry, id:int;
			var args:Array, selected:Boolean, hops:int;
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				id		   = nodeSprite.node.id;
				spritesCache[id] = nodeSprite;
				
				table = routing.findTable(nodeSprite.node, time);
				if (!table) {
					continue;
				}
				selected = nodeSprite.selected && (nodeSprite.selectedOrder == 1);
				if (selected && (drawState == "paths")) {
					continue;
				}
				else if (!selected && (drawState == "selected")) {
					continue;
				}
				
				var key:String, keyInv:String;
				var value:String, flag:Boolean;
				for (var j:int = 0, n:int = table.entries.length; j < n; j++) {
					entry = table.entries[j];
					hops  = entry.distance;
					args  = [];
					args.push((selected ? "+" : "-"));
					args.push(hops);
					args.push(id);
					
					if (hops == 1) {
						key		= String(id) + "," + String(entry.destination); 
						keyInv	= String(entry.destination) + "," + String(id); 
						args.push(entry.destination);
					}
					else {
						key 	= String(id) + "," + String(entry.next);
						keyInv	= String(entry.next) + "," + String(id); 
						args.push(entry.next);
						if (hops == 2) {
							args.push(entry.destination);
						}
					}
					
					flag  = (!(key in paths) && !(keyInv in paths)) || (((key in paths) || (keyInv in paths)) && selected);
					value = args.join(",");
					
					if (flag) {
						paths[key] = value;
						if (keyInv in paths) {
							delete paths[keyInv];
						}
					}
				}
			}
			
			routesShape.graphics.clear();
			var sid:int, nid:int, did:int;
			var source:NodeSprite, next:NodeSprite, dest:NodeSprite;
			var offset:int = 10;
			for each (var path:String in paths) {
				args 	 = path.split(",");
				selected = args[0] == "+";
				hops     = int(args[1]);
				sid      = int(args[2]);
				nid      = int(args[3]);
				next	 = null;
				
				if ((sid in spritesCache) && (nid in spritesCache)) {
					source = NodeSprite(spritesCache[sid]);
					next   = NodeSprite(spritesCache[nid]);
					if ((hops == 2) && selected) {
						did  = int(args[4]);
						if (did in spritesCache) {
							dest = spritesCache[did];
						}
					}
					drawPath(source, next, dest, hops, selected, offset);
				}
			}
		}
		
		/**
		 * Draw path
		 * 
		 * @param source
		 * @param next
		 * @param dest
		 * @param offset
		 */ 
		private function drawPath(source:NodeSprite, next:NodeSprite, dest:NodeSprite, hops:Number, selected:Boolean, offset:int):void
		{
			var sp:Point = new Point(source.x + offset, source.y + offset);
			var np:Point = new Point(next.x + offset, next.y + offset);
			var dp:Point;
			if (dest) {
				dp = new Point(dest.x + offset, dest.y + offset);
			}
			if (selected) {
				if (hops == 1) {
					routesShape.graphics.lineStyle(3, 0xff6622); //0x00bf00);
				}
				else if (hops == 2) {
					routesShape.graphics.lineStyle(3, 0x43C8Ef); // 0xFFF94A, 0xff6622
				}
				else {
					routesShape.graphics.lineStyle(3, 0xff4040);	
				}
			}
			else {
				routesShape.graphics.lineStyle(1, 0xcccccc);
			}
			routesShape.graphics.moveTo(sp.x, sp.y);
			routesShape.graphics.lineTo(np.x, np.y);
			if (dp) {
				routesShape.graphics.lineTo(dp.x, dp.y);
			}
		}
		
		/**
		 * Handle selected drawing manager change
		 * 
		 * @param event
		 */ 
		private function handleSelectedDrawingManagerChange(event:Event):void
		{
			invalidateState();
		}
	}
}