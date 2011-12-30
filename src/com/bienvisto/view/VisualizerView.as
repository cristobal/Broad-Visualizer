package com.bienvisto.view
{
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.ViewComponent;
	import com.bienvisto.view.drawing.IDrawingManager;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	/**
	 * VisualizerView.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class VisualizerView extends Group
	{	
		/**
		 * VisualizerView
		 */ 
		public function VisualizerView()
		{
			super();
			setup();
		}
		
		/**
		 * @private
		 */ 
		private var _viewComponents:Vector.<ViewComponent> = new Vector.<ViewComponent>();
		
		/**
		 * @readonly viewComponents
		 */ 
		public function get viewComponents():Vector.<ViewComponent>
		{
			return  _viewComponents;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint = 0;
		
		public function get time():uint
		{
			return _time;
		}
		
		public function setTime(time:uint):void
		{
			_time = time;
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{	
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		/**
		 * Add a view component
		 * 
		 * @param item
		 */ 
		public function addViewComponent(item:ViewComponent):void
		{
			_viewComponents.push(item);
			addElement(item);
		}
		
		
		/**
		 * Remove view component
		 * 
		 * @param item
		 */ 
		private function removeViewComponent(item:ViewComponent):void
		{
			var view:ViewComponent;
			for (var i:int = _viewComponents.length; i--;) {
				item = _viewComponents[i];
				if (view === item) {
					_viewComponents.splice(i, 1);
					removeChild(view);
				}
			}
		}
		
		/**
		 * Update
		 */ 
		private function update():void
		{	
			var viewComponent:ViewComponent;
			for (var i:int = 0, l:int = _viewComponents.length; i < l; i++) {
				viewComponent = _viewComponents[i];
				viewComponent.update(time);
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Timer
		//
		//--------------------------------------------------------------------------
		
		public function start():void
		{
			
		}
		
		public function pause():void
		{
			
		}
		
		public function stop():void
		{
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  Events
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Handle enter frame
		 * 
		 * @param event
		 */ 
		private function handleEnterFrame(event:Event):void
		{
			var time:int = getTimer();
			update();
		}
	}
}