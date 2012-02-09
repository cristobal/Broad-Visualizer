package com.bienvisto.view.drawing
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.utils.Dictionary;
	
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
		private static var windowSize:int = 100;
		
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
		 * @private
		 */ 
		private var states:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function reset():void
		{
			states   = new Dictionary();
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
				var nodeSprite:NodeSprite, node:Node;
				var total:int;
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					if (!nodeSprite.visibleInView) {
						continue;
					}
					
					node       = nodeSprite.node;
					
					total  = drops.sampleTotalWithWindowSize(node, time, windowSize);
					if (total == 0) {
						if (states[node.id]) {
							states[node.id] = false;
							nodeSprite.invalidate();
						}
							
						continue;
					}
					
					states[node.id] = time;
					nodeSprite.setHighlighted(highlightColor);
				}
				lastTime = time;
			}
			
		}
	}
}