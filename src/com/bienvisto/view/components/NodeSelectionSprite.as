package com.bienvisto.view.components
{
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	[Event(name="selected", type="com.bienvisto.view.events.NodeSpriteEvent")]
	
	/**
	 * Node selection sprite
	 * Sprite used to be clicked on which has an fixed size instead of using this since the size will vary depending on the child nodes
	 * @author Cristobal Dabed
	 */ 
	public final class NodeSelectionSprite extends Sprite
	{
		public function NodeSelectionSprite(nodeSprite:NodeSprite)
		{
			super();
			setup(nodeSprite);
		}
		
		/**
		 * @private
		 */ 
		private var _nodeSprite:NodeSprite;
		
		/**
		 * @readonly nodeSprite
		 */ 
		public function get nodeSprite():NodeSprite
		{
			return _nodeSprite;	
		}
		
		/**
		 * Setup
		 * 
		 * @param nodeSprite
		 */ 
		private function setup(nodeSprite:NodeSprite):void
		{
			_nodeSprite = nodeSprite;
			addEventListener(MouseEvent.CLICK, handleClick);
			
			invalidate();
			draw();
		}
		
		private function draw():void
		{
			var radius:Number = nodeSprite.radius;
			var cx:Number = radius;
			var cy:Number = radius;
			var alpha:Number =  0; // transparent
			graphics.moveTo(cx, cy);
			graphics.beginFill(0xFF00FF, alpha);
			graphics.drawCircle(cx, cy, radius + 3);
			graphics.endFill();
		}
		
		/**
		 * Invalidate
		 */ 
		public function invalidate():void
		{
			x = nodeSprite.x;
			y = nodeSprite.y;
		}
		
		/**
		 * Destoy
		 * 	Clean up and remove resources
		 */ 
		public function destroy():void
		{
			addEventListener(MouseEvent.CLICK, handleClick);
			_nodeSprite = null;
		}
		
		/**
		 * Handle click
		 * 
		 * @param event
		 */ 
		private function handleClick(event:MouseEvent):void
		{
			// nodeSprite.selected = !nodeSprite.selected; // Handled in NodeSelectionDrawingManager.as
			dispatchEvent(new NodeSpriteEvent(NodeSpriteEvent.SELECTED, false, false, nodeSprite));
		}
	}
}