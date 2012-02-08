package com.bienvisto.view.components
{
	import com.bienvisto.elements.mobility.MobilityArea;
	import com.bienvisto.util.DashedLine;
	
	import flash.events.Event;

	/**
	 * PerimeterView.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class PerimeterView extends ViewComponent
	{
		
		/**
		 * @private
		 */ 
		private static var lineColor:uint = 0x545454;
		
		public function PerimeterView(view:ViewComponent, mobilityArea:MobilityArea)
		{
			super();
			
			
			this.view		  = view;
			this.mobilityArea = mobilityArea;
			mobilityArea.addEventListener(Event.INIT, handleMobilityAreaInit);
		}
		
		/**
		 * @private
		 */ 
		private var view:ViewComponent;
		
		/**
		 * @private
		 */ 
		private var mobilityArea:MobilityArea;
		
		/**
		 * @override
		 */ 
		override public function reset():void
		{
			graphics.clear();
		}
		
		/**
		 * Setup
		 */ 
		public function setup():void
		{
			if (!view.contains(this)) {
				view.addChildAt(this, 0);	
			}
			
			var w:Number = mobilityArea.area.width;
			var h:Number = mobilityArea.area.height;
			
			graphics.lineStyle(1.5, lineColor, 0.65);
			
			DashedLine.moveTo(graphics, 0, 0);
			DashedLine.lineTo(graphics, w, 0);
			DashedLine.lineTo(graphics, w, h);
			
			DashedLine.moveTo(graphics, 0, 0);
			DashedLine.lineTo(graphics, 0, h);
			DashedLine.lineTo(graphics, w, h);
		}
			
		/**
		 * Handle mobility area init
		 */ 
		private function handleMobilityAreaInit(event:Event):void
		{
			setup();
		}
	}
}