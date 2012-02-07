package com.bienvisto.view.drawing
{
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.core.network.node.NodeContainer;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.routing.RoutingTable;
	import com.bienvisto.elements.routing.RoutingTableEntry;
	import com.bienvisto.elements.routing.SimpleRoute;
	import com.bienvisto.util.DashedLine;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.NodeView;
	
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * NodeRoutingDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeRoutingDrawingManager extends NodeDrawingManager
	{
		
		/**
		 * @private
		 */ 
		private static var linkColor:uint = 0xCCCCCC;
		/**
		 * @private
		 */
		private static var oneHopColor:uint = 0xFF6622;
		/**
		 * @private
		 */
		private static var twoHopColor:uint = 0x70FAA3;
		/**
		 * @private
		 */ 
		private static var threeHopColor:uint = 0xAA8888; 
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		public function NodeRoutingDrawingManager(routing:Routing, view:NodeView)
		{
			super("Routing");
			this.routing = routing;
			this.view = view;
			
			view.addChild(routesShape);
			_selectedDrawingManager.addEventListener(Event.CHANGE, handleDrawingManagerChange);
			_betweenNodesDrawingManager.addEventListener(Event.CHANGE, handleDrawingManagerChange);
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var dirty:Boolean;
		
		/**
		 * @private
		 */ 
		private var routing:Routing;
		
		/**
		 * @private
		 */
		private var view:NodeView;
		
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
		
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var _selectedDrawingManager:NodeRoutingSelectedDrawingManager = new NodeRoutingSelectedDrawingManager();
		
		/**
		 * @readonly selectedDrawingManager
		 */ 
		public function get selectedDrawingManager():NodeDrawingManager
		{
			return _selectedDrawingManager;
		}
		
		/**
		 * @private
		 */ 
		private var _betweenNodesDrawingManager:NodeRoutingBetweenNodesDrawingManager = new NodeRoutingBetweenNodesDrawingManager();
		
		/**
		 * @readonly betweenNodesDrawingManager
		 */ 
		public function get betweenNodesDrawingManager():NodeDrawingManager
		{
			return _betweenNodesDrawingManager;
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
			if (drawState != "none") {
				draw(time, nodeSprites);
				
				// lastTime = time;
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
			time = time - (time % DRAW_UPDATE_TIME);
			if ((view.selectedNodeSprite && view.selectedNodeSprite2) && betweenNodesDrawingManager.enabled) {
				drawRoutesBetweenNodes(time, nodeSprites);
			}
			else if (view.selectedNodeSprite) {
				drawSimpleRoutesSingle(time, nodeSprites);
			}
			else {
				drawSimpleRoutes(time, nodeSprites);
			}
		}
		
		/**
		 * Draw simple routes
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		private function drawSimpleRoutes(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			var drawSimple:Boolean   = drawState != "selected";
			if (!drawSimple) {
				clearGraphics();
				return;
			}
				
			var routes:Vector.<SimpleRoute> = routing.findSimpleRoutes(time);
			var spritesCache:Dictionary     = getSpritesCache(time, nodeSprites);
			
			clearGraphics();
			var from:int, dest:int;
			var route:SimpleRoute;
			var fromSprite:NodeSprite, destSprite:NodeSprite;
			var offset:int = 10
				
			for (var i:int = 0, l:int = routes.length; i < l; i++) {
				route = routes[i];
				from  = route.from;
				dest  = route.destination;
				
				fromSprite = NodeSprite(spritesCache[from]);
				destSprite = NodeSprite(spritesCache[dest]);
					
				if (fromSprite && destSprite) {
					drawSimplePath(fromSprite, destSprite, offset);
				}
			}
		}
		
		/**
		 * Draw simple routes single
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		private function drawSimpleRoutesSingle(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			var node:Node = view.selectedNodeSprite.node;
			var routes:Vector.<SimpleRoute> = routing.findSimpleRoutesWithNode(time, node);
			
			var spritesCache:Dictionary = getSpritesCache(time, nodeSprites);
			
			
			clearGraphics();
			
			var id:int = node.id;
			
			var from:int, next:int, dest:int;
			var route:SimpleRoute;
			var fromSprite:NodeSprite, nextSprite:NodeSprite, destSprite:NodeSprite;
			var offset:int = 10;
			var selected:Boolean;
			var hops:int = 0;
			
			var drawSelected:Boolean = drawState != "paths";
			var drawSimple:Boolean   = drawState != "selected";
			for (var i:int = 0, l:int = routes.length; i < l; i++) {
				route = routes[i];
				from  = route.from;
				next  = route.next;
				dest  = route.destination;
				hops  = route.distance;
				selected = from == id;
				if (selected && drawSelected) {
					fromSprite = NodeSprite(spritesCache[from]);
					nextSprite = NodeSprite(spritesCache[next]);
					destSprite = NodeSprite(spritesCache[dest]);
					
					if (fromSprite && (nextSprite || destSprite)) {
						drawSelectedPath(fromSprite, nextSprite, destSprite, hops, offset); // , true for arrow here 
					}
				}
				else if (drawSimple){
					fromSprite = NodeSprite(spritesCache[from]);
					destSprite = NodeSprite(spritesCache[dest]);
					
					if (fromSprite && destSprite) {
						drawSimplePath(fromSprite, destSprite, offset);
					}
				}
			}
		}
		
		/**
		 * Draw routes between nodes
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		private function drawRoutesBetweenNodes(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			var nodeFrom:Node = view.selectedNodeSprite.node;
			var nodeTo:Node   = view.selectedNodeSprite2.node;
			
			var routeFrom:SimpleRoute  = routing.findCompleteRoute(time, nodeFrom, nodeTo);
			var routeTo:SimpleRoute    = routing.findCompleteRoute(time, nodeTo, nodeFrom);
			
			var spritesCache:Dictionary = getSpritesCache(time, nodeSprites);
			clearGraphics();
			if (!routeFrom && !routeTo) {
				return; // no routes
			}
			
			if (routeFrom) {
				drawCompleteRoute(routeFrom, spritesCache);
			}
			
			if (routeTo) {
				drawCompleteRoute(routeTo, spritesCache);
			}
		}
		
		/**
		 * Draw complete route
		 * 
		 * @param route
		 * @param spritesCache
		 */ 
		private function drawCompleteRoute(route:SimpleRoute, spritesCache:Dictionary):void
		{
			var from:int = route.from;
			var dest:int = route.destination;
			var next:int = route.next;
			
			var hops:int = route.distance;
			var offset:Number = 10;
			var color:uint = oneHopColor;

			var thickness:Number = 3;
			if (hops == 1) {
				drawSimplePath(NodeSprite(spritesCache[from]), NodeSprite(spritesCache[dest]), offset, thickness, color, false, true);
			}
			else if (hops == 2) {
				color = twoHopColor;
				drawSimplePath(NodeSprite(spritesCache[from]), NodeSprite(spritesCache[next]), offset, thickness, color, false, true);
				drawSimplePath(NodeSprite(spritesCache[next]), NodeSprite(spritesCache[dest]), offset, thickness, color, false, true);
			}
			else if (hops > 2) {
				color = threeHopColor;
				
				var paths:Vector.<int> = route.paths;
				for (var i:int = 1, l:int = paths.length - 1; i < l; i++) {
					next = paths[i];
					if (next < 0) {
						break;
					}
					drawSimplePath(NodeSprite(spritesCache[from]), NodeSprite(spritesCache[next]), offset, thickness, color, false, true);
					from = next;
				}
				
				var dashed:Boolean = !route.complete;
				drawSimplePath(NodeSprite(spritesCache[from]), NodeSprite(spritesCache[dest]), offset, thickness, color, dashed, true);		
			}			
			
		}
		
		/**
		 * Draw simple path
		 * 
		 * @param source
		 * @param dest 
		 * @param offset
		 */ 
		private function drawSimplePath(source:NodeSprite, dest:NodeSprite, offset:int = 0, thickness:Number = 1, color:uint = 0xcccccc, dashed:Boolean = false, arrow:Boolean = false):void
		{
			if (!source && !dest) {
				return;
			}
			
			var from:Point = new Point(source.x + offset, source.y + offset);
			var to:Point = new Point(dest.x + offset, dest.y + offset);

			if (dashed) {
				drawDashedLine(from, to, thickness, color);
			}
			else {
				drawLine(from, to, thickness, color);
			}
			
			if (arrow) {
				drawArrow(from, to, thickness + 0.5, color, offset);
			}
		}

		
		/**
		 * Draw line
		 * 
		 * @param from
		 * @param to
		 * @param thickness
		 * @param color
		 */ 
		private function drawDashedLine(from:Point, to:Point, thickness:Number = 1, color:uint = 0xcccccc):void
		{
			routesShape.graphics.lineStyle(thickness, color);
			DashedLine.moveTo(routesShape.graphics, from.x, from.y);
			DashedLine.lineTo(routesShape.graphics, to.x, to.y);
			dirty = true;
		}
		
		/**
		 * Draw line
		 * 
		 * @param from
		 * @param to
		 * @param thickness
		 * @param color
		 */ 
		private function drawLine(from:Point, to:Point, thickness:Number = 1, color:uint = 0xcccccc):void
		{
			routesShape.graphics.lineStyle(thickness, color);
			routesShape.graphics.moveTo(from.x, from.y);
			routesShape.graphics.lineTo(to.x, to.y);
			dirty = true;
		}
		
		/**
		 * Draw lines
		 * 
		 * @param from
		 * @param to
		 * @param thickness
		 * @param color
		 */
		private function drawLines(from:Point, points:Vector.<Point>,  thickness:Number = 1, color:uint = 0xcccccc):void
		{
			routesShape.graphics.lineStyle(thickness, color);
			routesShape.graphics.moveTo(from.x, from.y);
			
			for each (var point:Point in points) {
				routesShape.graphics.lineTo(point.x, point.y);
			}
			dirty = true;
		}
		
		/**
		 * Draw path
		 * 
		 * @param source
		 * @param next
		 * @param dest
		 * @param hops
		 * @param offset
		 */ 
		private function drawSelectedPath(source:NodeSprite, next:NodeSprite, dest:NodeSprite, hops:Number, offset:int = 0, arrow:Boolean = false):void
		{
			var from:Point = new Point(source.x + offset, source.y + offset);
			var to:Point   = new Point(dest.x + offset, dest.y + offset);
			
			var nextPoint:Point;
			if (next) {
				nextPoint = new Point(next.x + offset, next.y + offset);	
			}
			
			var thickness:Number = 3;
			var color:uint      = oneHopColor;
			
			if (hops == 1) {
				drawLine(from, to, thickness, color);
			}
			else if (hops == 2) {
				color = twoHopColor;
				drawLines(from, Vector.<Point>([nextPoint, to]), thickness, color);
			}
			else if (hops > 2) {
				color = threeHopColor;
				drawLine(from, nextPoint, thickness, color);
				drawDashedLine(nextPoint, to, thickness, color);
			}
			
			if (arrow) {
				var start:Point = (nextPoint ? nextPoint : from)
				var end:Point   = to;
				drawArrow(start, end, thickness + 0.5, color, offset);
			}
		}
		
		/**
		 * Draw arrow
		 * 
		 * @param from
		 * @param to
		 * @param thickness
		 * @param color
		 */ 
		private function drawArrow(from:Point, to:Point, thickness:Number = 1.5, color:uint = 0xcccccc, offset:uint = 0):void
		{
			
			var angle:Number  = Math.atan2(to.y - from.y, to.x - from.x);
			var spread:Number = 0.65;
			var size:Number   = 20;
			
			var dx:Number = to.x - (offset * Math.cos(angle));
			var dy:Number = to.y - (offset * Math.sin(angle));
			
			routesShape.graphics.lineStyle(thickness, color);
			routesShape.graphics.moveTo(dx, dy);
			routesShape.graphics.lineTo(dx - Math.cos(angle + spread) * size, dy - Math.sin(angle + spread) * size);
			routesShape.graphics.moveTo(dx - Math.cos(angle - spread) * size, dy - Math.sin(angle - spread) * size);
			routesShape.graphics.lineTo(dx, dy);
			
			dirty = true;
		}
		
		/**
		 * Clear graphics
		 */ 
		private function clearGraphics():void
		{
			if (dirty) {
				routesShape.graphics.clear();
				dirty = false;
			}
		}
		
		
		/**
		 * @private
		 */ 
		private var lastSCTime:Number = -1;
		
		/**
		 * @private
		 */ 
		private var spritesCache:Dictionary;
		
		/**
		 * Get sprites cache
		 */ 
		private function getSpritesCache(time:uint, nodeSprites:Vector.<NodeSprite>):Dictionary
		{
			if (lastSCTime != time) {
				lastSCTime = time;
				spritesCache = null;
			}
			
			if (!spritesCache) {
				spritesCache = new Dictionary();
				
				var id:int;
				var nodeSprite:NodeSprite;
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					id		   = nodeSprite.node.id;
					spritesCache[id] = nodeSprite;
				}
			}
			
			return spritesCache;
		}
		
		
		/**
		 * Handle selected drawing manager change
		 * 
		 * @param event
		 */ 
		private function handleDrawingManagerChange(event:Event):void
		{
			invalidateState();
		}
		
	}
}