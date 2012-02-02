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
			var waypoint:Waypoint2D;
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				
				waypoint   = mobility.findWaypoint(nodeSprite.node, time); 
				if (waypoint) {
					var elapsed:int = time - waypoint.time;
					var vx:Number = (waypoint.direction.x / 1000) * elapsed;
					var vy:Number = (waypoint.direction.y / 1000) * elapsed;
					nodeSprite.x = waypoint.position.x + vx;
					nodeSprite.y = waypoint.position.y + vy;
				}
			}
		}
	}
}