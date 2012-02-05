package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.network.packet.Packet;
	import com.bienvisto.elements.network.packet.PacketStats;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.display.Shape;
	import flash.utils.Dictionary;
	
	/**
	 * NodeReceptionsDrawingManager.as
	 * 	Draws circles for the received packets.
	 * 
	 * @author Cristobal Dabed
	 */
	public final class NodeReceptionsDrawingManager extends NodeDrawingManager
	{
		
		//--------------------------------------------------------------------------
		//
		// Class variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private static var windowSize:int = 500;
		
		/**
		 * @private
		 */ 
		private static var highlightColor:uint = 0x70FAA3;
		
		/**
		 * @private
		 */ 
		private static var highlightColorOther:uint = 0xFFDA9E;
		
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * 
		 * @param receptions
		 */ 
		public function NodeReceptionsDrawingManager(receptions:Receptions)
		{
			super( "Receptions");
			this.receptions = receptions;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var receptions:Receptions;
		
		/**
		 * @private
		 */ 
		private var shapes:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var states:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var lastTime:uint = 0;
		
		
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
		}
		
		/**
		 * Draw 
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		private function draw(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			var nodeSprite:NodeSprite;
			var packetStats:PacketStats;
			var id:int;
			var shape:Shape;
			
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				id    = nodeSprite.node.id;
				shape = Shape(shapes[id]);
				
				packetStats = receptions.samplePacketStats(nodeSprite.node, time, windowSize);
				if (!packetStats) {
					if (states[id]) {
						states[id] = false;
						shape.graphics.clear();
					}
					continue;	
				}
				
				
				// If the reception is after the moment visualized, we just return
				if (time > packetStats.time) {
					if (states[id]) {
						states[id] = false;
						shape.graphics.clear();
					}
					continue;
				}
				
				
				if (!shape) {
					shape = new Shape();
					shape.visible = enabled;
					nodeSprite.addChildAt(shape, 0);
					shapes[id] = shape;
				}
				
				var cx:Number = nodeSprite.cx;
				var cy:Number = nodeSprite.cy;
				var radius:Number = 9 +  0.5 * (packetStats.totalOwn + 0.5 * packetStats.totalOther);
				
				shape.graphics.clear();
				
				shape.graphics.beginFill(highlightColorOther, 0.5);
				shape.graphics.drawCircle(cx, cy, radius);
				shape.graphics.endFill();
				
				radius =  9 + 0.5 * packetStats.totalOwn;
				
				shape.graphics.beginFill(highlightColor);
				shape.graphics.drawCircle(cx, cy, radius); 
				shape.graphics.endFill();
				
				states[id] = true;
				
			}
			
		}
		
	}
}