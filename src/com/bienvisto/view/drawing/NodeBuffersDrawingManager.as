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
			if ((lastTime != time) && enabled) {
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
			if (time != lastTime) {
				
				var nodeSprite:NodeSprite, shape:Shape, buffer:Buffer, size:Number;		
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					buffer = buffers.findBuffer(nodeSprite.node, time);
					shape  = getShape(nodeSprite);
					shape.graphics.clear();
					
					if (!buffer || time < buffer.time) {	
						continue;
					}
					
					size = buffer.size;
					if (size > 0) {
						shape.graphics.lineStyle(5, fillColor);
						shape.graphics.lineTo(0, -(size / 100));
					}
				}
				
				lastTime = time;
			}
		}
		
		/**
		 * Get shape
		 * 
		 * @param id
		 * @param nodeSprite
		 */ 
		private function getShape(nodeSprite:NodeSprite):Shape
		{
			var id:int = nodeSprite.node.id;
			if (id in shapes) {
				return Shape(shapes[id]);
			}
			
			var shape:Shape = new Shape();
			shape.x = nodeSprite.cx;
			shape.y = nodeSprite.cy;
			nodeSprite.addChild(shape);
			shapes[id] = shape;
			
			return shape;
		}
		
	}
}