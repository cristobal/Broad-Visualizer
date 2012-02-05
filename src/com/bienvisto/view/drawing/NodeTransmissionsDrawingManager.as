package com.bienvisto.view.drawing
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.packet.Packet;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.util.DashedLine;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	// TODO: Do not draw transmission arrows for already drawn destinations…
	/**
	 * NodeTransmissionsDrawingManager.as
	 * 
	 * @author Cristobal Dabed 
	 */ 
	public final class NodeTransmissionsDrawingManager extends NodeDrawingManager
	{
		
		//--------------------------------------------------------------------------
		//
		// Class Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private static var windowSizeTotal:int = 50;
		
		/**
		 * @private
		 */ 
		private static var windowSizePackets:uint = 500;
		
		/**
		 * Color used to highlight transmissions (any kind of transmitted 
		 * packet). In the visualization this corresponds to the nodes blinking
		 */
		private static var highlightColor:uint = 0xFFF94A;
		
		/**
		 * Color used to highlight communications (the arrow between source and
		 * destination)
		 */
		private static var arrowColor:uint = 0x6383FF;
		
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		public function NodeTransmissionsDrawingManager(transmissions:Transmissions, view:Sprite)
		{
			super("Transmissions");
			this.transmissions = transmissions;
			this.view = view;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
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
		private var transmissions:Transmissions;
		
		/**
		 * @private
		 */ 
		private var lastTime:uint = 0;
		
		/**
		 * @private
		 */ 
		private var dirty:Boolean;
		
		/**
		 * @private
		 */ 
		private var states:Dictionary = new Dictionary();
		
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
			for each(var shape:Shape in shapes) {
				shape.visible = enabled;
			}
			dirty = true;
			
			super.invalidate();
		}
		
		/**
		 * @override 
		 */ 
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			if ((time != lastTime) && enabled) {
				draw(time, nodeSprites);
				
				lastTime = time;
			}
			else if(dirty && !enabled) {
				dirty = false;
				
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprites[i].invalidate();
				}
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
			var nodeSprite:NodeSprite, nodeSpriteDest:NodeSprite;
			
			var cache:Dictionary = new Dictionary();
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				cache[nodeSprite.node.id] = nodeSprite;
			}
			
			// shape.graphics.clear();
			
			var points:Vector.<Point> = new Vector.<Point>();
			var origin:Point, end:Point;
			
			var packet:Packet, packets:Vector.<Packet>, shape:Shape, item:Aggregate;
			var total:int = 0, id:int = 0, offset:int = 10;
			for (i = 0; i < l; i++) {
				nodeSprite = nodeSprites[i];
				id = nodeSprite.node.id;
				
				if (!(id in shapes)) {
					shape = new Shape();
					shape.visible = enabled;
					view.addChild(shape);
					shapes[id] = shape;
				}
				else {
					shape = Shape(shapes[id]);
					view.addChildAt(shape, view.numChildren - 1); // push to top
				}
				
				item = transmissions.findNearest(nodeSprite.node, time);
				if (!item || time < item.time) {
					if (states[id]) {
						states[id] = false;
						shape.graphics.clear();
					}
					continue;
				}
				
				
				if ((item.time + windowSizeTotal > time) && enabled) {
					nodeSprite.setHighlighted(highlightColor);
				}
				else {
					nodeSprite.invalidate();
				}
				
				
				packets = transmissions.samplePackets(nodeSprite.node, time, windowSizePackets); 
				if (!packets) {
					if (states[id]) {
						states[id] = false;
						shape.graphics.clear();
					}
					continue;
				}
				
				shape.graphics.clear();	
				
				
				for (var j:int = 0, n:int = packets.length; j < n; j++) {
					packet = packets[j];
					if (!(packet.to in cache) || (packet.to == id)) {
						continue;
					}
					
					
					nodeSpriteDest = NodeSprite(cache[packet.to]);
					origin = new Point(nodeSprite.x + offset, nodeSprite.y + offset);
					end	   = new Point(nodeSpriteDest.x + offset, nodeSpriteDest.y + offset);
					
					drawArrow(shape, origin, end, offset);
					states[id] = true;
				}
				
			}	
			
		}
		
		/**
		 * Draw arrow
		 * 
		 * @param shape
		 * @param origin 
		 * @param end
		 * @param offset
		 */ 
		private function drawArrow(shape:Shape, origin:Point, end:Point, offset:uint = 0):void
		{	
			var angle:Number, spread:Number, size:Number;
			
			angle  = Math.atan2(end.y - origin.y, end.x - origin.x);
			spread = 0.5;
			size   = 20;
			end.x -= offset * Math.cos(angle);
			end.y -= offset * Math.sin(angle);
			
			
			shape.graphics.lineStyle(2.5, arrowColor);
			DashedLine.moveTo(shape.graphics, origin.x, origin.y);
			DashedLine.lineTo(shape.graphics, end.x, end.y);
			
/*			shape.graphics.moveTo(origin.x, origin.y);
			shape.graphics.lineTo(end.x, end.y);*/
			shape.graphics.lineTo(end.x-Math.cos(angle+spread)*size, end.y-Math.sin(angle+spread)*size);
			shape.graphics.moveTo(end.x-Math.cos(angle-spread)*size, end.y-Math.sin(angle-spread)*size);
			shape.graphics.lineTo(end.x, end.y);
		}
	}
}