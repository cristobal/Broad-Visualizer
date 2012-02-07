package com.bienvisto.ui.windows.charts
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.IDataRenderer;
	
	import spark.components.HSlider;
	
	public final class ResolutionSlider extends HSlider
	{
		public function ResolutionSlider()
		{
			super();
		}
		
		override protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void 
		{
			try {
				super.updateDataTip(dataTipInstance, initialPosition);
			}catch (error:Error) {}
			// do nothing.
		}
		
		override protected function system_mouseUpHandler(event:Event):void
		{
			try {
				super.system_mouseUpHandler(event);
			}catch(error:Error) {}
			// do nothing…
		}
		
		override protected function thumb_mouseDownHandler(event:MouseEvent):void
		{
			try {
				super.thumb_mouseDownHandler(event);
			}catch(error:Error) {};
		}
	}
}