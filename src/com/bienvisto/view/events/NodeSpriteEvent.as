package com.bienvisto.view.events
{
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.events.Event;
	
	/**
	 * NodeSpriteEvent.as 
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeSpriteEvent extends Event
	{
		
		public static const SELECTED:String = "selected";
		
		public function NodeSpriteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, nodeSprite:NodeSprite = null)
		{
			super(type, bubbles, cancelable);
			
			_nodeSprite = nodeSprite;
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
		
		
		override public function clone():Event
		{
			return new NodeSpriteEvent(type, bubbles, cancelable, nodeSprite);
		}
	}
}