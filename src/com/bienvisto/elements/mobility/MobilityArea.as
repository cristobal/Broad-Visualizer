package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * MobilityArea.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class MobilityArea extends TraceSource
	{
		
		public function MobilityArea()
		{
			super("MobilityArea", "ma");
		}
		
		/**
		 * @private
		 */ 
		private var _area:Rectangle;
		
		/**
		 * @readonly area
		 */ 
		public function get area():Rectangle 
		{
			return _area;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// FORMAT: ma x1_area1 x2_area1 y1_area1 y2_area1
			var x1:Number = Number(params[1]);
			var x2:Number = Number(params[2]);
			var y1:Number = Number(params[3]);
			var y2:Number = Number(params[4]);
			
			var width:Number = Math.abs(x2 - x1);
			var height:Number = Math.abs(y2 - y1);
			
			_area = new Rectangle(x1, y1, width, height);
			dispatchEvent(new Event(Event.CHANGE));
			
			return 0;
		}
		
	}
}