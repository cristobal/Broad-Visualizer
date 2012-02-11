package com.gran.view.drawing
{
	import com.gran.elements.mobility.Mobility;
	import com.gran.elements.mobility.Waypoint2D;
	import com.gran.view.components.NodeSprite;
	import com.gran.view.components.ViewComponent;
	
	import flash.display.DisplayObject;
	
	import mx.managers.SystemManager;
	
	/**
	 * NodeMobilityDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeMobilityDrawingManager extends NodeDrawingManager
	{
		public function NodeMobilityDrawingManager(mobility:Mobility, view:ViewComponent)
		{
			super("Mobility");
			this.mobility = mobility;
			this.view     = view;
		}
		
		/**
		 * @private
		 */ 
		private var mobility:Mobility;
		
		/**
		 * @private
		 */ 
		private var view:ViewComponent;
		
		/**
		 * @override
		 */ 
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>, needsInvalidation:Boolean = false):void
		{
			var nodeSprite:NodeSprite;
			var waypoint:Waypoint2D;
			
			var root:DisplayObject = view.systemManager.getSandboxRoot();
			
			
			var sw:Number = root.width;
			var sh:Number = root.height;
			
			var vx:Number = view.x;
			var vy:Number = view.y;
			
			for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				
				waypoint   = mobility.findWaypoint(nodeSprite.node, time); 
				if (waypoint) {
					var elapsed:int = time - waypoint.time;
					nodeSprite.x = waypoint.position.x + (waypoint.direction.x / 1000) * elapsed;
					nodeSprite.y = waypoint.position.y + (waypoint.direction.y / 1000) * elapsed;
				}
				
				// wether the nodeSprite is visible in the view
				nodeSprite.visibleInView = !((nodeSprite.x + vx > sw || nodeSprite.x + vx < 0) || (nodeSprite.y + vy > sh || nodeSprite.y + vy < 0));
			}
		}
	}
}