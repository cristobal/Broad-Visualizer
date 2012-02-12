package com.broad.view.drawing
{
	import com.broad.core.network.node.Node;
	import com.broad.core.network.packet.Packet;
	import com.broad.core.network.packet.PacketStats;
	import com.broad.elements.mobility.Mobility;
	import com.broad.elements.mobility.Waypoint2D;
	import com.broad.elements.receptions.Receptions;
	import com.broad.view.components.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.utils.Dictionary;
	
	import mx.managers.SystemManager;
	
	/**
	 * NodeReceptionsDrawingManager.as
	 * 	Draws circles for the received packets.
	 * 	
	 *  Most expensive drawing of them all.
	 *  Uses about 30-40ms when cached and more when not.
	 * 
	 *  Could be optimized further to not draw circle for nodes that are not visible but also requires 
	 *  more logic to be handled when window resizes and when user drags the windows around.
	 *  In additions to calculating if the nodeSprite is actually visible. 
	 *  This should be managed outside by the nodeSprite.
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
		private var stats:Dictionary  = new Dictionary();
		
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
		 * @override
		 */ 
		override public function reset():void
		{
			shapes   = new Dictionary();
			states   = new Dictionary();
			stats    = new Dictionary();
			
			lastTime = 0;
		}
		
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
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>, needsInvalidation:Boolean = false):void
		{
			if (!enabled) {
				return;
			}
			
			
			if (time != lastTime || needsInvalidation) {
				
				var nodeSprite:NodeSprite;
				
				var opacketStats:PacketStats;
				var packetStats:PacketStats;
				var id:int;
				var shape:Shape;
				
				var cx:Number, cy:Number;
				var radius:Number, radiusOwn:Number;
				
				var vx:Number, vy:Number;
				
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					if (!nodeSprite.visibleInView) {
						continue;
					}
					
					id    = nodeSprite.node.id;
					shape = Shape(shapes[id]);
					
					
					packetStats = receptions.samplePacketStats(nodeSprite.node, time, windowSize);
					
					// If no packets stats or the reception is after the moment visualized, we just return
					if (!packetStats || time > packetStats.time) {
						if (states[id]) {
							stats[id]  = null;
							states[id] = false;
							shape.graphics.clear();
						}
						continue;	
					}
					
					opacketStats = PacketStats(stats[id]);
					stats[id]    = packetStats;
					
					if (opacketStats && (opacketStats.totalOther == packetStats.totalOther) && (opacketStats.totalOwn == packetStats.totalOwn)) {
						continue; // we are drawing the same as before just continue to next
					}
					
					if (!shape) {
						shape = new Shape();
						shape.visible = enabled;
						nodeSprite.addChildAt(shape, 0);
						shapes[id] = shape;
					}
					
					cx = nodeSprite.cx;
					cy = nodeSprite.cy;
					
					shape.graphics.clear();
					radius    =  9 + 0.5 * (packetStats.totalOwn + 0.5 * packetStats.totalOther);
					radiusOwn =  9 + 0.5 *  packetStats.totalOwn;
					
					
					// only draw to others
					if (packetStats.totalOther > 0 && packetStats.totalOwn == 0) {
						shape.graphics.beginFill(highlightColorOther, 0.5);
						shape.graphics.drawCircle(cx, cy, radius);
						shape.graphics.endFill();					
					}
						
						// only draw to myself
					else if (packetStats.totalOwn > 0 && packetStats.totalOther == 0) {
						shape.graphics.beginFill(highlightColor);
						shape.graphics.drawCircle(cx, cy, radiusOwn); 
						shape.graphics.endFill();
					}
						
						// draw both
					else {
						shape.graphics.beginFill(highlightColorOther, 0.5);
						shape.graphics.drawCircle(cx, cy, radius);
						shape.graphics.endFill();	
						
						shape.graphics.beginFill(highlightColor);
						shape.graphics.drawCircle(cx, cy, radiusOwn); 
						shape.graphics.endFill();
					}
					
					states[id] = true;
					
				}
				
				lastTime = time;
			}
		}
		
	}
}