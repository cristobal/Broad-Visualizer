package com.bienvisto.ui.menus
{
	import com.bienvisto.core.events.TimedEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IDataRenderer;
	import mx.core.LayoutDirection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.PopUpUtil;
	
	import spark.components.Button;
	import spark.components.HSlider;
	import spark.skins.spark.HSliderSkin;
	
	/**
	 * @Event
	 * 	Dispatched when a new value has been set.
	 */ 
	[Event(name="elapsed", type="com.bienvisto.core.events.TimedEvent")]
	
	/**
	 * ProgressSlider.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class ProgressTimeSlider extends HSlider
	{
		
		/**
		 * @Event
		 * 	Dispatched when a value starts changing its value
		 */ 
		[Event(name="changeStart", type="flash.events.Event")]
		public static const CHANGE_START:String = "changeStart";
		
		/**
		 * @Event
		 * 	Dispatched when a value change ends
		 */ 
		[Event(name="changeEnd", type="flash.events.Event")]
		public static const CHANGE_END:String = "changeEnd";
		
		/**
		 * @Event
		 * 	Dispatched when loading starts
		 */
		[Event(name="loadStart", type="flash.events.Event")]
		public static const LOAD_START:String = "loadStart";
		
		/**
		 * @Event
		 * 	Dispatched when loading ends
		 */ 
		[Event(name="loadEnd", type="flash.events.Event")]
		public static const LOAD_END:String = "loadEnd";
		
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//--------------------------------------------------------------------------
		/**
		 * Constructore
		 */ 
		public function ProgressTimeSlider()
		{
			super();
			setup();
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var component:UIComponent; 

		/**
		 * @private
		 */ 
		private var loading:Boolean;
		
		/**
		 * @private
		 */ 
		private var loadingValue:Number = 0.0;
		
		/**
		 * @private
		 */ 
		private var thumbStart:Boolean;
		
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function set width(value:Number):void
		{
			super.width = value;	
			invalidate();
		}
		
		/**
		 * @override
		 */ 
		override protected function setValue(value:Number):void
		{
			super.setValue(value);
			if (_time != value && !_timeFlag) {
				
				// invalidate bufffering
				var w:Number  = width - 2;
				var ew:Number = w;
				var tw:Number = w;
				
				var flag:Boolean = false;
				
				if (value < duration) {
					ew = (ew * value) / duration;
				}
				
				var wx:Number = (ew / w) * 100;		
				if ((loaded < 100) && (wx > loaded)) {
					setBuffering(true);
				}
				
				dispatchEvent(new TimedEvent(TimedEvent.ELAPSED, false, false, value));
				
				var dx:Number = (value / duration) * 100;
				if ((dx > loaded)) {
					loading = true;
					loadingValue = Math.ceil(dx);
					dispatchEvent(new Event(LOAD_START));
				}
				else if ((dx < loaded) && loading) {
					loading = false;
					dispatchEvent(new Event(LOAD_END));
				}
				
			}
			_timeFlag = false;
			invalidate();
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint;
		
		/**
		 * @private
		 */ 
		private var _timeFlag:Boolean
		
		/**
		 * @readwrite time
		 */ 
		public function set time(value:uint):void
		{
			_time = value;
			super.value = value;
			_timeFlag = true;
			invalidate();
		}
		
		public function get time():uint
		{
			return super.value;
		}
		
		/**
		 * @private
		 */ 
		private var _loaded:Number = 0;
		
		/**
		 * @readwrite loaded
		 */ 
		public function set loaded(value:Number):void
		{
			if (value < 0) {
				value = 0;
			}
			else if (value > 100) {
				value = 100;
			}
			
			
			_loaded = value;
			if ((loadingValue < loaded) && loading) {
				loading = false;
				dispatchEvent(new Event(LOAD_END));
			}
			
			invalidate();
		}
		
		/**
		 * @readwrite loaded
		 */ 
		public function get loaded():Number
		{
		 	return _loaded;	
		}
		
		/**
		 * @readonly
		 */ 
		public function get loadComplete():Boolean
		{
			return _loaded == 100;
		}
		
		/**
		 * @private
		 */ 
		private var _buffering:Boolean;
		
		/**
		 * @readonly buffering
		 */ 
		public function get buffering():Boolean
		{
			return _buffering;
		}
		
		public function setBuffering(value:Boolean):void
		{
			_buffering = value;
		}
		
		/**
		 * @readwrite duration
		 */
		public function get duration():Number
		{
			return maximum;
		}
		 
		public function set duration(value:Number):void
		{
			maximum = value;
			invalidateDuration();
		}
		
		/**
		 * @private
		 */ 
		private var _durationProgressEnabled:Boolean;
		
		/**
		 * @readwrite usePogress
		 */ 
		public function set durationProgressEnabled(value:Boolean):void
		{
			_durationProgressEnabled = value;
			invalidateDuration();
		}
		
		public function get durationProgressEnabled():Boolean
		{
			return _durationProgressEnabled;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			if (!initialized) {
				return;
			}
			
			draw();
		}
		
		/**
		 * Invalidate duration
		 */ 
		private function invalidateDuration():void
		{
			if (!initialized) {
				return;
			}
			
			if (durationProgressEnabled) {
				var value:Number = duration / (width / 2);
				if (value < 1) {
					value = 1;
				}
				
				value    = int(value);
				stepSize = value;
				
			}
			
			component.visible = durationProgressEnabled;
		}
		
		/**
		 * Init components
		 */
		private function initComponents():void
		{
			var thumb:Button = HSliderSkin(skin).thumb;
			var index:int = skin.getChildIndex(thumb);
			
			component = new UIComponent();
			HSliderSkin(skin).addElementAt(component, index);
			HSliderSkin(skin).addElementAt(thumb, index + 1);
		}
		
		/**
		 * Bind components
		 */ 
		private function bindComponents():void
		{
			HSliderSkin(skin).thumb.addEventListener(FlexEvent.BUTTON_DOWN, handleThumbButtonDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleStageMouseUp);
		}
		
		/**
		 * Draw
		 */ 
		private function draw():void
		{
			if (durationProgressEnabled) {
				component.graphics.clear();
				if (time > 0) {
					
					var w:Number  = width - 2;
					var ew:Number = w;
					var tw:Number = w;
			
					var flag:Boolean = false;
					
					if (value < duration) {
						ew = (ew * value) / duration;
					}
					
					var wx:Number = (ew / w) * 100;		
					if ((loaded < 100) && (wx > loaded)) {
						tw = ew;
						ew = w * (loaded / 100);
						flag = true;
					}
					setBuffering(flag);
					
					if (flag) {
						// 0xb30000, 0xc00909
						component.graphics.beginFill(0xdd4b39, 0.5); 
						component.graphics.drawRect(1, 4, tw, 3);
						component.graphics.endFill();
					}
					
					component.graphics.beginFill(0xc80909); 
					component.graphics.drawRect(1, 4, ew, 3);
					component.graphics.endFill();
				}
			}	
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Overriden Methods
		//
		//-------------------------------------------------------------------------
				
		/**
		 * @override
		 */ 
		override protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void
		{
			var tipAsDisplayObject:DisplayObject= dataTipInstance as DisplayObject;
			
			if (tipAsDisplayObject && thumb)
			{
				dataTipInstance.data = int(value);
				
				// If this component's coordinate system is RTL (x increases to the right), then
				// getLayoutBoundsX() returns the right edge, not the left.
				// We are working in thumb.parent coordinates and we assume that there's no scale factor
				// between the tooltip and the thumb.parent.
				const tipWidth:Number = tipAsDisplayObject.width;
				var relX:Number = thumb.getLayoutBoundsX() - (tipWidth - thumb.getLayoutBoundsWidth()) / 2;
				if (layoutDirection == LayoutDirection.RTL) {
					relX += tipAsDisplayObject.width;
				}
				
				// Get the tips bounds. We only care about the dimensions.
				var tipBounds:Rectangle = tipAsDisplayObject.getBounds(tipAsDisplayObject.parent);
				
				// Ensure that we don't overlap the screen
				var pt:Point = PopUpUtil.positionOverComponent(thumb.parent,
					systemManager,
					tipBounds.width, 
					tipBounds.height,
					NaN,
					null,
					new Point(relX, initialPosition.y));
				
				// The point is in sandboxRoot coordinates, however tipAsDisplayObject is paranted to systemManager,
				// convert to tipAsDisplayObject's parent coordinates
				pt = tipAsDisplayObject.parent.globalToLocal(systemManager.getSandboxRoot().localToGlobal(pt));
				
				tipAsDisplayObject.x = Math.floor(pt.x);
				tipAsDisplayObject.y = Math.floor(pt.y);
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Events
		//
		//-------------------------------------------------------------------------
		
		
		/**
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		private function handleCreationComplete(event:FlexEvent):void
		{
			initComponents();
			invalidate()
		}
		
		/**
		 * Handle added to stage
		 * 
		 * @param event
		 */ 
		private function handleAddedToStage(event:Event):void
		{
			bindComponents();
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Thumb skin events
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle thumb button down
		 * 
		 * @param event
		 */ 
		private function handleThumbButtonDown(event:FlexEvent):void
		{
	
			if (!thumbStart) {
				
		
				thumbStart = true;
				dispatchEvent(new Event(CHANGE_START));
			}
		}
		
		/**
		 * Handle stage mouse up
		 * 
		 * @param event
		 */ 
		private function handleStageMouseUp(event:MouseEvent):void
		{
			
			if (thumbStart) {	
				
				thumbStart = false;
				dispatchEvent(new Event(CHANGE_END));
			}
		}
		
	}
}