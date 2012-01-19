package com.bienvisto.ui.menu
{
	import com.bienvisto.core.events.TimedEvent;
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
	
	[Event(name="elapsed", type="com.bienvisto.core.events.TimedEvent")]
	
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
		public var timeSlider:ProgressTimeSlider;
		
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
		 * Bind components
		 */ 
		protected function bindComponents():void
		{
			timeSlider.addEventListener(TimedEvent.ELAPSED, handleProgressSliderChangeValue);
			// timeSlider.addEventListener(ProgressTimeSlider.LOAD_START, handleProgressSliderLoadStart);
			// timeSlider.addEventListener(ProgressTimeSlider.LOAD_END, handleProgressSliderLoadEnd);
		}
		
		/**
		 * Set loaded
		 * 
		 * @param value
		 */ 
		public function setLoaded(value:Number):void
		{
			
			value = int(value);
			if (value > timeSlider.loaded) {
				timeSlider.loaded = value;
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
			timeLabel.text  = text;
			
			timeSlider.time = value / 1000;
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
			timeSlider.duration = value / 1000;
			timeSlider.enabled  = true;
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
	 	 * Handle progress slider change value
		 * 
		 * @param event
		 */
		protected function handleProgressSliderChangeValue(event:TimedEvent):void
		{
			dispatchEvent(new TimedEvent(TimedEvent.ELAPSED, false, false, event.elapsed * 1000));
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
			bindComponents();
		}
		
	}
}