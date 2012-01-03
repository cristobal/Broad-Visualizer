package com.bienvisto.view.components
{
	import flash.events.Event;

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
		private static var spacing:uint = 20;
		
		
		public function GridView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			draw();
			stage.addEventListener(Event.RESIZE, handleResize);	
		}
		
		/**
		 * @override
		 */ 
		override public function set scale(value:Number):void
		{
			if (value < 0.5) {
				value = 0.5;
			}
			super.scale = value;
		}
		
		/**
		 * @override
		 */ 
		override protected function invalidateScale():void {
			super.invalidateScale();
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
			
			if (scale < 1.0) {
				var factor:Number = 100 * (1.0 - scale);
				w *= factor;
				h *= factor;
			}
			
			graphics.clear();
			
			// draw horizontal lines
			for (var y:int = -1, pos:int = 0; y < h; y += spacing, pos++) {
				if (pos % 5 == 0) {
					graphics.lineStyle(1, thickLineColor, 0.65);
				}
				else {
					graphics.lineStyle(1, thinLineColor, 0.65);
				}
				
				graphics.moveTo(0, y);
				graphics.lineTo(w, y);
			}
			
			// draw vertical lines
			pos = 0;
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