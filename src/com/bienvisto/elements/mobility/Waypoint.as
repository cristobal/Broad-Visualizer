package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.aggregate.Aggregate;
	
	/**
	 * Waypoint.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class Waypoint extends Aggregate
	{
		public function Waypoint(time:uint, position:Vector2D)
		{
			super(time);
			_position = position;
		}
		
		/**
		 * @private
		 */ 
		private var _position:Vector2D;
		
		/**
		 * @reaonly position
		 */ 
		public function get position():Vector2D
		{
			return _position;
		}
	}
}