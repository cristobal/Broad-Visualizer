package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.network.Packet;
	import com.bienvisto.elements.network.PacketStats;
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
	public final class NodeReceptionsDrawingManager implements INodeDrawingManager
	{
		/**
		 * @private
		 */ 
		private static var windowSize:uint = 500;
		
		/**
		 * @private
		 */ 
		private static var highlightColor:uint = 0x70FAA3;
		
		/**
		 * @private
		 */ 
		private static var highlightColorOther:uint = 0xFFDA9E;
		
		/**
		 * Constructor
		 * 
		 * @param receptions
		 */ 
		public function NodeReceptionsDrawingManager(receptions:Receptions)
		{
			this.receptions = receptions;
		}
		
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
		private var lastTime:uint = 0;
		
		/**
		 * Update
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			var nodeSprite:NodeSprite;
			var packetStats:PacketStats;
			var id:int;
			var shape:Shape;
			
			if (time != lastTime) {
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
				
					packetStats = receptions.samplePacketStats(nodeSprite.node, time, windowSize);
					if (packetStats) {
					
						// trace(packetStats.node.id, packetStats.totalOther, packetStats.totalOwn);
						// If the reception is after the moment visualized, we just return
						if (time < packetStats.time) {
							return;
						}
					
						id = nodeSprite.node.id;
						if (!(id in shapes)) {
							shape = new Shape();
							nodeSprite.addChildAt(shape, 0);
							shapes[id] = shape;
						}
						else {
							shape = Shape(shapes[i]);
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
					}
				}
				lastTime = time;
			}
		}
		
	}
}