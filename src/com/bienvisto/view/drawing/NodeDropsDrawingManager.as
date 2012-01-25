package com.bienvisto.view.drawing
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.view.components.NodeSprite;
	
	/**
	 * NodeDropsDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeDropsDrawingManager extends NodeDrawingManager
	{
		/**
		 * @private
		 */ 
		private static var windowSize:uint = 100;
		
		/**
		 * @private
		 */ 
		private static var highlightColor:uint = 0xff0000;
		
		
		public function NodeDropsDrawingManager(drops:Drops)
		{
			super("Drops");
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
		 * @overridej
		 */ 
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			if (!enabled) {
				return;	
			}
			
			if (lastTime != time) {
				var nodeSprite:NodeSprite;
				var samples:Vector.<Aggregate>;
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					
					samples    = drops.sampleItems(nodeSprite.node, time, windowSize);
					if (!samples || samples.length == 0) {
						continue;
					}
					
					trace("samples… for node: ", nodeSprite.node.id, "total:", samples.length, time, "vs.", samples[0].time);
					nodeSprite.setHighlighted(highlightColor);
					
				}
				lastTime = time;
			}
			
		}
		
	}
}