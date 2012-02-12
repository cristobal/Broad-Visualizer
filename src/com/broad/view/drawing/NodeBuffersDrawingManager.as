package com.broad.view.drawing
{
	import com.broad.elements.buffer.Buffer;
	import com.broad.elements.buffer.Buffers;
	import com.broad.view.components.NodeSprite;
	
	import flash.display.Shape;
	import flash.utils.Dictionary;
	
	/**
	 * NodeBufferDrawinManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeBuffersDrawingManager extends NodeDrawingManager
	{
		
		//--------------------------------------------------------------------------
		//
		// Class variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private static var fillColor:uint = 0xAA8888;
		
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		public function NodeBuffersDrawingManager(buffers:Buffers)
		{
			super("buffers");
			this.buffers = buffers;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
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
			shapes = new Dictionary();
			states = new Dictionary();
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
			
			if (lastTime != time || needsInvalidation) {
				
				var nodeSprite:NodeSprite,  id:int; 
				var shape:Shape, buffer:Buffer, size:Number;		
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					if (!nodeSprite.visibleInView) {
						continue;
					}
					
					buffer = buffers.findBuffer(nodeSprite.node, time);
					shape  = Shape(shapes[id]);
					
					if (!buffer || time < buffer.time) {	
						if (states[id]) {
							states[id] = false;
							shape.graphics.clear();
						}
						continue;
					}
					
					
					if (!shape) {
						shape = new Shape();
						shape.x = nodeSprite.cx;
						shape.y = nodeSprite.cy;
						nodeSprite.addChild(shape);
						shapes[id] = shape;
					}
					
					size = buffer.size;
					if (size > 0) {
						shape.graphics.lineStyle(5, fillColor);
						shape.graphics.lineTo(0, -(size / 100));
						states[id] = true;
					}
				}
				
				lastTime = time;
			}
		}
		
	}
}