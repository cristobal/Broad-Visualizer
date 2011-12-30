package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.buffer.Buffer;
	import com.bienvisto.elements.buffer.Buffers;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.display.Shape;
	import flash.utils.Dictionary;
	
	/**
	 * NodeBufferDrawinManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeBufferDrawingManager implements INodeDrawingManager
	{
		/**
		 * @private
		 */ 
		private static var fillColor:uint = 0xAA8888;
		
		public function NodeBufferDrawingManager(buffers:Buffers)
		{
			this.buffers = buffers;
		}
		
		/**
		 * @private
		 */ 
		private var buffers:Buffers;
		
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
			var shape:Shape;
			var id:int;
			var buffer:Buffer;
			if (time != lastTime) {
				
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					buffer = buffers.findBuffer(nodeSprite.node, time);
					if (!buffer) {
						continue;
					}
					
					if (time < buffer.time) {
						continue;
					}
					
					if (!(id in shapes)) {
						shape = new Shape();
						shape.x = nodeSprite.cx;
						shape.y = nodeSprite.cy;
						nodeSprite.addChild(shape);
						
						shapes[id] = shape;
					}
					else {
						shape = Shape(shapes[id]);
					}
					
					var size:Number = buffer.size;
					if (size > 0) {
						var value:Number = size / 100;
						
						shape.graphics.clear();
						shape.graphics.lineStyle(5, fillColor);
						shape.graphics.lineTo(0, -value);
					}
				}
				
				lastTime = time;
			}
		}
		
	}
}