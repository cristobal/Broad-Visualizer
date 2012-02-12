package com.broad.ui.menus
{
	import com.broad.core.events.TimedEvent;
	import com.broad.util.sprintf;
	import com.broad.view.components.ViewComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.BorderContainer;
	import spark.components.CheckBox;
	import spark.components.Label;
	import spark.components.NumericStepper;
	
	/**
	 * @Event
	 * 	Dispatched when a new timed event requesting a new elapsed point in time for the simulation 
	 * 	handled by the application window and the Bienvisto container.
	 */ 
	[Event(name="elapsed", type="com.broad.core.events.TimedEvent")]
	
	/**
	 * @Event
	 * 	Dispatched when the playback progress has started changing
	 */ 
	[Event(name="changeStart", type="flash.events.Event")]
	
	/**
	 * @Event
	 * 	Dispatched when the playback progress has changed
	 */ 
	[Event(name="changeEnd", type="flash.events.Event")]
	
	/**
	 * @Event
	 * 	Dispatched when the playback progress has started loading
	 */
	[Event(name="loadStart", type="flash.events.Event")]
	
	/**
	 * @Event
	 * 	Dispatched when the playback progress has stopped loading
	 */
	[Event(name="loadEnd", type="flash.events.Event")]
	
	
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
		public var miniMapCheckbox:CheckBox;
		
		/**
		 * @public 
		 */ 
		public var perimeterCheckbox:CheckBox;
		
		/**
		 * @public
		 */ 
		public var statsCheckbox:CheckBox;
		
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
		 * @protected
		 */ 
		protected var miniMapView:ViewComponent;
		
		/**
		 * @protected
		 */ 
		protected var perimeterView:ViewComponent;
		
		/**
		 * @protected
		 */ 
		protected var statsView:ViewComponent;
		
		/**
		 * @readonly buffering
		 */ 
		public function get buffering():Boolean
		{
			var value:Boolean = false;
			if (timeSlider) {
				value = timeSlider.buffering;
			}
			return value;
		}

		/**
		 * Set zoom view
		 * 
		 * @param view
		 */ 
		public function addZoomView(view:ViewComponent):void
		{
			zoomViews.push(view);
			invalidateGridView();
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
		 * Set mini map view
		 * 
		 * @param miniMapView
		 */ 
		public function setMiniMapView(miniMapView:ViewComponent):void
		{
			this.miniMapView = miniMapView;
			invalidateMiniMapView();
		}
		
		/**
		 * Invalidate mini map
		 */ 
		protected function invalidateMiniMapView():void
		{
			if (miniMapView && miniMapCheckbox) {
				miniMapView.visible = miniMapCheckbox.selected;
			}
		}
		
		/**
		 * Set perimeter view
		 * 
		 * @param perimeterView
		 */ 
		public function setPerimeterView(perimeterView:ViewComponent):void
		{
			this.perimeterView = perimeterView;
			invalidatePerimeterView();
		}
		
		/**
		 * Invalidate perimeter
		 */ 
		protected function invalidatePerimeterView():void
		{
			if (perimeterView && perimeterCheckbox) {
				perimeterView.visible = perimeterCheckbox.selected;
			}
		}
		
		/**
		 * Set stats view
		 * 
		 * @param statsView
		 */ 
		public function setStatsView(statsView:ViewComponent):void
		{
			this.statsView = statsView;
			this.statsView.x = 10;
			this.statsView.y = 40;
			invalidateStatsView();
		}
		
		/**
		 * Invalidate stats
		 */ 
		protected function invalidateStatsView():void
		{
			if (statsView && statsCheckbox) {
				statsView.visible = statsCheckbox.selected;
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
			invalidateGridView();
		}
		
		protected function invalidateGridView():void
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
				gridCheckbox.addEventListener(Event.CHANGE, handleGridCheckboxChange);
			}
			if (miniMapCheckbox) {
				miniMapCheckbox.addEventListener(Event.CHANGE, handleMiniMapCheckboxChange);
			}
			if (perimeterCheckbox) {
				perimeterCheckbox.addEventListener(Event.CHANGE, handlePerimeterCheckboxChange);
			}
			if (statsCheckbox) {
				statsCheckbox.addEventListener(Event.CHANGE, handleStatsCheckboxChange);
			}
			if (zoomLevel) {
				zoomLevel.addEventListener(Event.CHANGE, handleZoomLevelChange);
			}
		}
		
		/**
		 * Bind components
		 */ 
		protected function bindComponents():void
		{
			timeSlider.addEventListener(TimedEvent.ELAPSED, handleProgressSliderChangeValue);
			timeSlider.addEventListener(ProgressTimeSlider.CHANGE_START, handleProgressSliderChangeStart);
			timeSlider.addEventListener(ProgressTimeSlider.CHANGE_END, handleProgressSliderChangeEnd);
			timeSlider.addEventListener(ProgressTimeSlider.LOAD_START, handleProgressSliderLoadStart);
			timeSlider.addEventListener(ProgressTimeSlider.LOAD_END, handleProgressSliderLoadEnd);
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
		 * Get time
		 */ 
		public function getTime():uint
		{
			return timeSlider.time * 1000;
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
		 * Handle mini map check box change
		 * 
		 * @param event
		 */ 
		protected function handleMiniMapCheckboxChange(event:Event):void
		{
			invalidateMiniMapView();	
		}
		
		/**
		 * Handle perimeter check box change
		 * 
		 * @param event
		 */ 
		protected function handlePerimeterCheckboxChange(event:Event):void
		{
			invalidatePerimeterView();
		}
		
		/**
		 * Handle grid checkbox change
		 * 
		 * @param event
		 */ 
		protected function handleGridCheckboxChange(event:Event):void
		{
			invalidateGridView();
		}
		
		/**
		 * Handle stats checkbox change
		 * 
		 * @param event
		 */ 
		protected function handleStatsCheckboxChange(event:Event):void
		{
			invalidateStatsView();
		}
		
		/**
		 * Handle zoom level change
		 * 
		 * @param event
		 */ 
		protected function handleZoomLevelChange(event:Event):void
		{
			invalidateGridView();
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
		 * Handle progress slider change start
		 * 
		 * @param event
		 */ 
		protected function handleProgressSliderChangeStart(event:Event):void
		{
			dispatchEvent(event); // forward the event
		}
		
		/**
		 * Handle progress slider change end
		 * 
		 * @param event
		 */ 
		protected function handleProgressSliderChangeEnd(event:Event):void
		{
			dispatchEvent(event); // forward the event
		}
		
		/**
		 * Handle progress slider load start
		 * 
		 * @param event
		 */ 
		protected function handleProgressSliderLoadStart(event:Event):void
		{
			dispatchEvent(event); // forward the event
		}
		
		/**
		 * Handle progress slider load end
		 * 
		 * @param event
		 */ 
		protected function handleProgressSliderLoadEnd(event:Event):void
		{
			dispatchEvent(event); // forward the event
		}	
		
	}
}