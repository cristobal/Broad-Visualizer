package com.gran.view.components
{
	import com.gran.util.sprintf;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.controls.Label;
	
	import spark.components.Application;

	[Event(name="change", type="flash.events.Event")];
	
	/**
	 * GridView.as
	 * 	View component that manages the grid.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class GridView extends ViewComponent
	{
		
		/**
		 * @private
		 */ 
		private static var thinLineColor:uint = 0xE6F8FF;
		
		/**
		 * @private
		 */ 
		private static var thickLineColor:uint = 0xD4EDFF;
		
		/**
		 * @private
		 */ 
		private static var scaleColor:uint = 0x696969;
		
		/**
		 * @private
		 */ 
		private static var spacing:uint = 20;
		
		/**
		 * @private
		 */ 
		private static var bottomSpacing:uint = 50;
		
		public function GridView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		/**
		 * @private
		 */ 
		private var textField:TextField;
		
		/**
		 * @private
		 */ 
		private var textFormat:TextFormat;
		
		/**
		 * @private
		 */ 
		private var _totalVerticalBoxes:Number = 0;
		
		/**
		 * @readonly totalThickLines
		 */ 
		public function get totalVerticalBoxes():Number
		{
			return _totalVerticalBoxes;
		}
		
		/**
		 * @private
		 */ 
		private var _verticalLineYPos:Number = 0;
		
		/**
		 * @readonly verticalSpace
		 */ 
		public function get verticalLineYPos():Number
		{
			return _verticalLineYPos;
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			stage.addEventListener(Event.RESIZE, handleResize);	
			
			textFormat = new TextFormat("DejaVuSansDF3", 11, scaleColor, true);
			textFormat.align = TextAlign.RIGHT;
			
			textField  = new TextField();
			textField.embedFonts = true;
			textField.text = "100 meters";
			textField.setTextFormat(textFormat);
			
			textField.x = 0;
			textField.width = 146;
			textField.backgroundColor = 0xFF00FF;
			textField.background = false;
			addChild(textField);
			
			draw();
		}
		
		/**
		 * @override
		 */ 
		override public function set scale(value:Number):void
		{
			// do not scale this view
			// if (value < 0.5) {
			// 	value = 0.5;
			// }
			super.scale = value;
		}
		
		/**
		 * @override
		 */ 
		override protected function invalidateScale():void {
			// do not invalidateScale()
			// super.invalidateScale();
			invalidate();
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			draw();
		}
		
		/**
		 * Draw
		 */ 
		private function draw():void
		{
			var w:Number = parent.width;
			var h:Number = parent.height;
			
			/*
			if (scale < 1.0) {
				var factor:Number = 100 * (1.0 - scale);
				w *= factor;
				h *= factor;
			}
			*/
			
			graphics.clear();
			_totalVerticalBoxes = 0;
			// draw horizontal lines
			for (var y:int = -1, pos:int = -1; y < h; y += spacing, pos++) {
				if (pos % 5 == 0) {
					_totalVerticalBoxes++;
					graphics.lineStyle(1, thickLineColor, 0.65);
				}
				else {
					graphics.lineStyle(1, thinLineColor, 0.65);
				}
				
				graphics.moveTo(0, y);
				graphics.lineTo(w, y);
			}
			
			// draw vertical lines
			pos = -1;
			for (var x:int = -1; x < w; x += spacing, pos++) {
				if (pos % 5 == 0) {
					graphics.lineStyle(1, thickLineColor, 0.65);
				}
				else {
					graphics.lineStyle(1, thinLineColor, 0.65);
				}
				
				graphics.moveTo(x, 0);
				graphics.lineTo(x, h);
			}
			
			
			// draw vertical line
			x = spacing;
			y = h - bottomSpacing;
			y -= (y % spacing);
			if ((h - y) < (bottomSpacing + (spacing / 2))) {
				y -= spacing;
			}
			_verticalLineYPos = y;
			
			graphics.lineStyle(2, scaleColor);
			graphics.moveTo(x, y);
			
			x += spacing * 5;
			graphics.lineTo(x, y);
			
			graphics.lineStyle(1, scaleColor);
			
			y -= spacing / 4;
			graphics.lineTo(x, y);
			
			if (textField) {
				var meters:int = int(100 * scale);
				textField.text = sprintf("%d meters", meters);
				textField.setTextFormat(textFormat);
				textField.y    = y - 15;
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Handle added to stage
		 * 
		 * @param event
		 */ 
		private function handleAddedToStage(event:Event):void
		{
			setup();
		}
		
		/**
		 * Handle resize
		 * 
		 * @param event
		 */ 
		private function handleResize(event:Event):void
		{
			if (stage.width > width || stage.height > height) {
				invalidate();
			}
		}
		
		/**
		 * @override
		 */ 
		override public function update(time:uint):void
		{
			
		}
	}
}