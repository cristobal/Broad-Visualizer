package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.routing.RoutingTable;
	import com.bienvisto.elements.routing.RoutingTableEntry;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	// TODO: Optimize drawing to use one shape and draw only paths needed…
	/**
	 * NodeRoutingDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeRoutingDrawingManager implements INodeDrawingManager
	{
		public function NodeRoutingDrawingManager(routing:Routing, view:Sprite)
		{
			this.routing = routing;
			this.view = view;
		}
		
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
		private var shapes:Dictionary = new Dictionary();
	
		/**
		 * @private
		 */ 
		private var lastTime:uint = 0;
		
		/**
		 * @readonly name
		 */ 
		public function get name():String
		{
			return "Routing";
		}
		
		/**
		 * @private
		 */ 
		private var _enabled:Boolean = true;
		
		/**
		 * @readwrite enabled
		 */ 
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			invalidate();
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			for each(var shape:Shape in shapes) {
				shape.visible = enabled;
			}
		}
		
		/**
		 * Update
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			if (lastTime != time) {
				var nodeSprite:NodeSprite, nodeSpriteDest:NodeSprite;
				
				var spritesCache:Dictionary = new Dictionary();
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					spritesCache[nodeSprite.node.id] = nodeSprite;
				}
				
				var table:RoutingTable, id:int, shape:Shape;
				for (i = 0; i < l; i++) {
					nodeSprite = nodeSprites[i];
					id = nodeSprite.node.id;
					
					if (!(id in shapes)) {
						shape = new Shape();
						shape.visible = enabled;
						view.addChildAt(shape, 0);
						shapes[id] = shape;
					}
					else {
						shape = Shape(shapes[id]);
						view.addChildAt(shape, 0); // push to top
					}
					
					table = routing.findTable(nodeSprite.node, time);
					if (!table) {
						if ((time % 1000) == 0) {
							shape.graphics.clear();
						}
						continue;
					}
					
					shape.graphics.clear();
					var entries:Vector.<RoutingTableEntry> = table.entries, entry:RoutingTableEntry;
					var offset:int  = 10;
					for (var j:int = 0, n:int = entries.length; j < n; j++) {
						entry = entries[j];
						drawPath(nodeSprite, shape, entry, spritesCache, offset);
					}
				}
				
				lastTime = time;
			}
		}
		
		
		public function drawPath(nodeSprite:NodeSprite, shape:Shape, entry:RoutingTableEntry, spritesCache:Dictionary, offset:int):void
		{
			var dest:int = entry.destination;
			var next:int = entry.next;
			var hops:int = entry.distance;
			
			var nodeSpriteDest:NodeSprite = NodeSprite(spritesCache[next]);
			
			if (hops == 1) {
				nodeSpriteDest = NodeSprite(spritesCache[dest]);
				// next = -1;
			}
			else if (next && hops > 2) {
				nodeSpriteDest =  NodeSprite(spritesCache[next]);
				// next = -1;
			}
			
			if (nodeSpriteDest) {
				var origin:Point = new Point(nodeSprite.x + offset, nodeSprite.y + offset);
				var end:Point = new Point(nodeSpriteDest.x + offset, nodeSpriteDest.y + offset);
				if (nodeSprite.selected) {
					shape.graphics.lineStyle(3, 0xff6622);
				}
				else {
					shape.graphics.lineStyle(1, 0xcccccc);
				}
				shape.graphics.moveTo(origin.x, origin.y);
/*				if (next) {
					shape.graphics.lineTo(next.x, next.y);
				}*/
				shape.graphics.lineTo(end.x, end.y);
			}
		}
	}
}