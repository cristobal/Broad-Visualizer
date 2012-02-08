package com.bienvisto.view.drawing
{
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * NodeDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class NodeDrawingManager extends EventDispatcher implements IDrawingManager
	{
		/**
		 * @readonly
		 */ 
		public static const DRAW_UPDATE_TIME:uint = 300;
		
		public function NodeDrawingManager(name:String)
		{
			super();
			this._name = name;
		}
		
		/**
		 * @private
		 */ 
		private var _name:String;
		
		/**
		 * @readonly name
		 */ 
		public function get name():String
		{
			return _name;
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
			invalidate();
		}
		
		public function set scale(value:Number):void
		{
			
		}
		
		/**
		 * Invalidate
		 */ 
		protected function invalidate():void
		{
			dispatchEvent(new Event(Event.CHANGE)); 
		}
		
		/**
		 * Reset
		 */ 
		public function reset():void
		{
			
		}
		
		/**
		 * Update 
		 * 
		 * @param time
		 * @param nodeSprites
		 */ 
		public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			
		}
	}
}