package com.bienvisto.view.drawing
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.view.components.NodeSprite;
	
	public final class NodeDropsDrawingManager implements INodeDrawingManager
	{
		/**
		 * @private
		 */ 
		private static var windowSize:uint = 50;
		
		/**
		 * @private
		 */ 
		private static var highlightColor:uint = 0xff0000;
		
		public function NodeDropsDrawingManager(drops:Drops)
		{
			this.drops = drops;
		}
		
		/**
		 * @private
		 */ 
		private var drops:Drops;
		
		/**
		 * @private
		 */ 
		private var lastTime:uint = 0;
		
		/**
		 * @readonly name
		 */ 
		public function get name():String
		{
			return "Drops";
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
			// invalidate();
		}
		
		public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			if (!enabled) {
				return;	
			}
			
			var nodeSprite:NodeSprite;
			var samples:Vector.<Aggregate>;
			if (lastTime != time) {
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					
					samples    = drops.sampleItems(nodeSprite.node, time, windowSize);
					if (!samples || samples.length == 0) {
						continue;
					}
					
					nodeSprite.setHighlighted(highlightColor);
					
				}
				lastTime = time;
			}
		}
	}
}