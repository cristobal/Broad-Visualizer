package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.network.Node;
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
			if (view.selectedNodeSprite && view.selectedNodeSprite2) {
				drawSimpleRoutesComplex(time, nodeSprites);
			}
			else if (view.selectedNodeSprite) {
				drawSimpleRoutesSingle(time, nodeSprites);
			}
			else {
				drawSimpleRoutes(time, nodeSprites);
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
			
			var id:int;
			var nodeSprite:NodeSprite;
			var spritesCache:Dictionary = new Dictionary();
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				id 		   = nodeSprite.node.id;
				spritesCache[id] = nodeSprite;
			}
			id = node.id;
			
			routesShape.graphics.clear();
			var from:int, next:int, dest:int, broken:Boolean;
			var route:SimpleRoute;
			var fromSprite:NodeSprite, nextSprite:NodeSprite, destSprite:NodeSprite;
			var offset:int = 10;
			var selected:Boolean;
			var hops:int = 0;
			var drawSelected:Boolean = drawState != "paths";
			var drawSimple:Boolean   = drawState != "selected";
			for (i = 0, l = routes.length; i < l; i++) {
				route = routes[i];
				from  = route.from;
				next  = route.next;
				dest  = route.destination;
				hops  = route.distance;
				broken = route.broken;
				selected = from == id;
				if (selected && drawSelected) {
					fromSprite = NodeSprite(spritesCache[from]);
					nextSprite = NodeSprite(spritesCache[next]);
					destSprite = NodeSprite(spritesCache[dest]);
					
					if (fromSprite && (nextSprite || destSprite)) {
						drawSelectedPath(fromSprite, nextSprite, destSprite, hops, broken, offset); 
					}
				}
				else if (drawSimple){
					fromSprite = NodeSprite(spritesCache[from]);
					destSprite = NodeSprite(spritesCache[dest]);
				
					if (fromSprite && destSprite) {
						drawSimplePath(fromSprite, destSprite, broken, offset);
					}
				}
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
				return;
			}
			
			var routes:Vector.<SimpleRoute> = routing.findSimpleRoutes(time);
			
			var id:int;
			var nodeSprite:NodeSprite;
			var spritesCache:Dictionary = new Dictionary();
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				id 		   = nodeSprite.node.id;
				spritesCache[id] = nodeSprite;
			}
			
			routesShape.graphics.clear();
			var from:int, dest:int, broken:Boolean;
			var route:SimpleRoute;
			var fromSprite:NodeSprite, destSprite:NodeSprite;
			var offset:int = 10
				
			for (i = 0, l = routes.length; i < l; i++) {
				route = routes[i];
				from  = route.from;
				dest  = route.destination;
				broken = route.broken;
				
				fromSprite = NodeSprite(spritesCache[from]);
				destSprite = NodeSprite(spritesCache[dest]);
					
				if (fromSprite && destSprite) {
					drawSimplePath(fromSprite, destSprite, broken, offset);
				}
			}
		}
		
		/**
		 * Draw simple routes complex
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		private function drawSimpleRoutesComplex(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			
			var nodeFrom:Node = view.selectedNodeSprite.node;
			var nodeTo:Node   = view.selectedNodeSprite2.node;
			
			var routesFrom:Vector.<SimpleRoute> = routing.findCompleteRoute(time, nodeFrom, nodeTo);
			// var routesTo:Vector.<SimpleRoute>   = routing.findCompleteRoute(time, nodeTo, nodeFrom);
			
			var id:int;
			var nodeSprite:NodeSprite;
			var spritesCache:Dictionary = new Dictionary();
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				id 		   = nodeSprite.node.id;
				spritesCache[id] = nodeSprite;
			}
			
			routesShape.graphics.clear();
			if (routesFrom.length == 0) {
				return;
			}
			
			var from:int, dest:int, broken:Boolean;
			var route:SimpleRoute;
			var fromSprite:NodeSprite, destSprite:NodeSprite;
			var offset:int = 10;
			var thickness:Number = 3;
			var color:uint      = 0xff6622; // 0xAA8888; //0x43C8EF; //0x00bf00);
			var dashed:Boolean  = false;
			var hops:uint 		= routesFrom.length;
			var lastRoute:SimpleRoute = routesFrom[routesFrom.length - 1];
			var complete:Boolean = lastRoute.destination == nodeTo.id;
			if (hops == 2 && complete) {
				color = 0x70FAA3; // 0x43C8EF; // , 0xFFF94A, 0xff6622
			}
			else if (hops > 2 || !complete) {
				color = 0xff4040;
			}
			
			for (i = 0, l = routesFrom.length; i < l; i++) {
				route = routesFrom[i];
				from  = route.from;
				dest  = route.destination;
				broken = route.broken;
				
				fromSprite = NodeSprite(spritesCache[from]);
				destSprite = NodeSprite(spritesCache[dest]);
				
				if (fromSprite && destSprite) {
					drawSimplePath(fromSprite, destSprite, broken, offset, thickness, color, false, true);
				}
			}
			
			if (!complete) {
				from = lastRoute.from;
				dest = nodeTo.id;
				fromSprite = NodeSprite(spritesCache[from]);
				destSprite = NodeSprite(spritesCache[dest]);
				
				if (fromSprite && destSprite) {
					drawSimplePath(fromSprite, destSprite, broken, offset, thickness, color, true, true);
				}
			}
			
		}
		
		/**
		 * Draw simple path
		 * 
		 * @param source
		 * @param dest
		 * @param broken 
		 * @param offset
		 */ 
		private function drawSimplePath(source:NodeSprite, dest:NodeSprite, broken:Boolean = false, offset:int = 0, thickness:Number = 1, color:uint = 0xcccccc, dashed:Boolean = false, arrow:Boolean = false):void
		{
			var from:Point = new Point(source.x + offset, source.y + offset);
			var to:Point = new Point(dest.x + offset, dest.y + offset);

			// if (broken) drawDashedLine(from, to);
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
			routesShape.graphics.lineStyle(thickness, color); //0x00bf00);
			DashedLine.moveTo(routesShape.graphics, from.x, from.y);
			DashedLine.lineTo(routesShape.graphics, to.x, to.y);
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
			routesShape.graphics.lineStyle(thickness, color); //0x00bf00);
			routesShape.graphics.moveTo(from.x, from.y);
			routesShape.graphics.lineTo(to.x, to.y);
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
			routesShape.graphics.lineStyle(thickness, color); //0x00bf00);
			routesShape.graphics.moveTo(from.x, from.y);
			
			for each (var point:Point in points) {
				routesShape.graphics.lineTo(point.x, point.y);
			}
		}
		
		/**
		 * Draw path
		 * 
		 * @param source
		 * @param next
		 * @param dest
		 * @param hops
		 * @param broken
		 * @param offset
		 */ 
		private function drawSelectedPath(source:NodeSprite, next:NodeSprite, dest:NodeSprite, hops:Number, broken:Boolean = false, offset:int = 0):void
		{
			var from:Point = new Point(source.x + offset, source.y + offset);
			var to:Point   = new Point(dest.x + offset, dest.y + offset);
			
			var nextPoint:Point;
			if (next) {
				nextPoint = new Point(next.x + offset, next.y + offset);	
			}
			
			var thicknes:Number = 3;
			var color:uint      = 0xff6622; //0x00bf00);
			var dashed:Boolean  = false;
			if (hops == 2) {
				color = 0x70FAA3; //0x43C8EF; // 0xFFF94A, 0xff6622
			}
			else if (hops > 2) {
				color = 0xff4040;
				
				to        = nextPoint;
				nextPoint = null;
				dashed    = true;
			}
			
			if (nextPoint) {
				drawLines(from, Vector.<Point>([nextPoint, to]), thicknes, color);
			}
			else {
				if (dashed) {
					drawDashedLine(from, to, thicknes, color);
				}
				else {
					drawLine(from, to, thicknes, color);
				}
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