package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.Waypoint2D;
	import com.bienvisto.view.components.NodeSprite;
	
	/**
	 * NodeMobilityDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeMobilityDrawingManager extends NodeDrawingManager
	{
		public function NodeMobilityDrawingManager(mobility:Mobility)
		{
			super("Mobility");
			this.mobility = mobility;
		}
		
		/**
		 * @private
		 */ 
		private var mobility:Mobility;
		
		/**
		 * @override
		 */ 
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			var nodeSprite:NodeSprite;
			var waypoint2D:Waypoint2D;
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				
				waypoint2D   = mobility.findWaypoint(nodeSprite.node, time); 
				if (waypoint2D) {
					var elapsed:int = time - waypoint2D.time;
					var vx:Number = (waypoint2D.direction.x / 1000) * elapsed;
					var vy:Number = (waypoint2D.direction.y / 1000) * elapsed;
					nodeSprite.x = waypoint2D.position.x + vx;
					nodeSprite.y = waypoint2D.position.y + vy;
				}
			}
		}
	}
}