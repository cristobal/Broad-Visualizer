package com.bienvisto.ui.menu
{
	import com.bienvisto.util.sprintf;
	import com.bienvisto.view.components.GridView;
	import com.bienvisto.view.components.ViewComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.BorderContainer;
	import spark.components.CheckBox;
	import spark.components.Label;
	import spark.components.NumericStepper;
	
	/**
	 * PlaybackContainer.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class PlaybackContainer extends BorderContainer
	{
		
		/**
		 * @protected
		 */
		protected static var secondsPerMinut:uint = 60;
		
		/**
		 * @protected
		 */ 
		protected static var secondsPerHour:uint  = 60 * secondsPerMinut;
		
		public function PlaybackContainer()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
		}
		
		/**
		 * @public
		 */ 
		public var timeLabel:Label;
		
		/**
		 * @public
		 */ 
		public var durationLabel:Label;
		
		/**
		 * @public
		 */ 
		public var gridCheckbox:CheckBox;
		
		/**
		 * @public
		 */ 
		public var zoomLevel:NumericStepper;
		
		/**
		 * @public
		 */ 
		public var playbackSpeed:NumericStepper;

		/**
		 * @protected
		 */ 
		protected var zoomViews:Vector.<ViewComponent> = new Vector.<ViewComponent>();
		
		
		/**
		 * @protected
		 */ 
		protected var gridView:ViewComponent;

		/**
		 * Set zoom view
		 * 
		 * @param view
		 */ 
		public function addZoomView(view:ViewComponent):void
		{
			zoomViews.push(view);
			invalidate();
		}
		
		/**
		 * Remove zoom view
		 * 
		 * @param view
		 */ 
		public function removeZoomView(view:ViewComponent):void
		{
			var item:ViewComponent;
			for (var i:int = zoomViews.length; i--;) {
				item = ViewComponent(zoomViews[i]);
				if (view === item) {
					zoomViews.splice(i, 1);
					
					// reset scale
					view.scale = 1;
					break;
				}
			}
		}
		
		/**
		 * Set gridview
		 * 
		 * @param view
		 */ 
		public function setGridView(view:ViewComponent):void
		{
			this.gridView = view;
			invalidate();
		}
		
		/**
		 * @readwrite grid view visible
		 */ 
		public function get gridViewVisible():Boolean
		{
			return gridView ? gridView.visible : false;
		}
		
		public function set gridViewVisible(value:Boolean):void
		{
			if (gridCheckbox) {
				gridCheckbox.selected = value;
			}
		}
		
		protected function invalidate():void
		{
			if (gridView && gridCheckbox) {
				gridView.visible = gridCheckbox.selected;
			}
			
			if (zoomViews.length > 0) {
				var scale:Number = zoomLevel.value / 100;
				var view:ViewComponent;
				for (var i:int = 0, l:int = zoomViews.length; i < l; i++) {
					view = zoomViews[i];
					view.scale = scale;
				}
			}
			
		}
		
		/**
		 * Init components 
		 */ 
		protected function initComponents():void
		{
			if (gridCheckbox) {
				gridCheckbox.addEventListener(Event.CHANGE, handleGridCheckboxChange, false, 0, true);
			}
			if (zoomLevel) {
				zoomLevel.addEventListener(Event.CHANGE, handleZoomLevelChange, false, 0, true);
			}
			if (playbackSpeed) {
				// playbackSpeed.incrementButton.addEventListener(MouseEvent.CLICK, handlePlaybackSpeedIncrement, false, int.MAX_VALUE, true);
			}
		}
		
		/**
		 * Set time
		 * 
		 * @param value
		 */ 
		public function setTime(value:uint):void
		{
			var text:String = miliSecondsToText(value);
			timeLabel.text = text;
		}
		
		/**
		 * Set duration
		 * 
		 * @param value Total duration value in ms
		 */ 
		public function setDuration(value:uint):void
		{
			var text:String = miliSecondsToText(value);
			durationLabel.text = text;
		}
		
		/**
		 * Miliseconds to text
		 * 
		 * 
		 * @param value The amount of ms
		 * @return The text as a time text in the format hh:mm:ss
		 */ 
		private function miliSecondsToText(value:uint):String
		{
			value = value / 1000;
			
			var hours:int = Math.floor(value / secondsPerHour);
			value -= hours * secondsPerHour;
			
			var minutes:int = Math.floor(value / secondsPerMinut);
			value -= minutes * secondsPerMinut;
			
			
			return sprintf("%02d:%02d:%02d", hours, minutes, value);
		}
		
		/**
		 * Handle grid checkbox change
		 * 
		 * @param event
		 */ 
		protected function handleGridCheckboxChange(event:Event):void
		{
			invalidate();
		}
		
		/**
		 * Handle zoom level change
		 * 
		 * @param event
		 */ 
		protected function handleZoomLevelChange(event:Event):void
		{
			invalidate();
		}
		
		/**
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		protected function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			initComponents();
		}
		
	}
}