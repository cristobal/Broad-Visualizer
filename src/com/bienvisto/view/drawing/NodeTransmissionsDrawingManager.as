package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.network.Packet;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.utils.Dictionary;
	
	/**
	 * NodeTransmissionsDrawingManager.as
	 * 
	 * @author Cristobal Dabed 
	 */ 
	public class NodeTransmissionsDrawingManager implements INodeDrawingManager
	{
		/**
		 * @private
		 */ 
		private static var windowSize:uint = 50;
		
		/**
		 * A communication will be rendered if it occured in the last 
		 * COMMUNICATION_HIGHLIGHTING_WINDOW milliseconds
		 */
		protected static const COMMUNICATION_HIGHLIGHTING_WINDOW:uint = 500;
		
		/**
		 * Color used to highlight communications (the arrow between source and
		 * destination)
		 */
		protected static const COMMUNICATION_HIGHLIGHT_COLOR:uint = 0x6383FF;
		
		/**
		 * Color used to highlight transmissions (any kind of transmitted 
		 * packet). In the visualization this corresponds to the nodes blinking
		 */
		protected static const highlightColor:uint = 0xFFF94A;
		
		public function NodeTransmissionsDrawingManager(transmissions:Transmissions)
		{
			this.transmissions = transmissions;
		}
		
		/**
		 * @private
		 */ 
		private var transmissions:Transmissions;
		
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
			var nodeSpriteDest:NodeSprite;
			var packets:Vector.<Packet>;
			var packet:Packet;
			var cache:Dictionary;
			if (time != lastTime) {
				
				cache = new Dictionary();
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					cache[nodeSprite.node.id] = nodeSprite;
				}
				
				for (i = 0; i < l; i++) {
					nodeSprite = nodeSprites[i];
					
					packets = transmissions.samplePackets(nodeSprite.node, time, windowSize);
					if (!packets || packets.length == 0) {
						continue;
					}
					
					nodeSprite.setHighlighted(highlightColor);
					
					
					/*if (packets.length > 0) {
						nodeSprite.highlighted = true;
						for (var j:int = 0, n:int = packets.length; j < n; j++) {
							packet = packets[j];
							if (!(packet.to in cache)) {
								continue;
							}
							nodeSpriteDest = NodeSprite(cache[packet.to]);
							
							var angle:Number = Math.atan2(nodeSpriteDest.y - nodeSprite.y, nodeSpriteDest.x-nodeSprite.x);
							var spread:Number = 0.5;
							var size:Number = 20;
							// nodeSpriteDest.x -= 10*Math.cos(angle);
							// nodeSpriteDest.y -= 10*Math.sin(angle);
							
							nodeSprite.graphics.lineStyle(2, COMMUNICATION_HIGHLIGHT_COLOR);
							nodeSprite.graphics.moveTo(nodeSprite.x, nodeSprite.y);
							nodeSprite.graphics.lineTo(nodeSpriteDest.x, nodeSpriteDest.y);
							nodeSprite.graphics.lineTo(nodeSpriteDest.x-Math.cos(angle+spread)*size, nodeSpriteDest.y-Math.sin(angle+spread)*size);
							nodeSprite.graphics.moveTo(nodeSpriteDest.x-Math.cos(angle-spread)*size, nodeSpriteDest.y-Math.sin(angle-spread)*size);
							nodeSprite.graphics.lineTo(nodeSpriteDest.x, nodeSpriteDest.y);
							
						}
					}*/
				}
				lastTime = time;
			}
		}
	}
}