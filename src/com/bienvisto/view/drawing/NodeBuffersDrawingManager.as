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
	public final class NodeBuffersDrawingManager implements INodeDrawingManager
	{
		/**
		 * @private
		 */ 
		private static var fillColor:uint = 0xAA8888;
		
		public function NodeBuffersDrawingManager(buffers:Buffers)
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
		 * @readonly name
		 */ 
		public function get name():String
		{
			return "Buffers";
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