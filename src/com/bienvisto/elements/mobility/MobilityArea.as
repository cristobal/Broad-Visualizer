package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * @Event
	 * 	The init event will be dispatched when the mobility area has been parsed.
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * MobilityArea.as
	 *  A trace source parser for the defined mobility area for an simulation.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class MobilityArea extends TraceSource implements ISimulationObject
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		 
		/**
		 * Constructor
		 */ 
		public function MobilityArea()
		{
			super("MobilityArea", "ma");
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  area
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _area:Rectangle;
		
		/**
		 * @readonly area
		 * 	The rectable area for the simulation
		 */ 
		public function get area():Rectangle 
		{
			return _area;
		
		}
		
		//--------------------------------------------------------------------------
		//
		//  Parsing Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// FORMAT: ma x1_area1 x2_area1 y1_area1 y2_area1
			var x:Number = Number(params[0]);
			var y:Number = Number(params[1]);
			var width:Number = Number(params[2]);
			var height:Number = Number(params[3]);
			
			_area = new Rectangle(x, width, width, height);
			dispatchEvent(new Event(Event.INIT));
			
			return 0;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  ISimulation Object Implementation
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On time update
		 * 
		 * @param elapsed
		 */ 
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
		
		/**
		 * Set duration
		 * 
		 * @param duration
		 */
		public function setDuration(duration:uint):void
		{
			
		}
		
		/**
		 * Reset
		 */ 
		public function reset():void
		{
			_area = null;
		}
		
	}
}