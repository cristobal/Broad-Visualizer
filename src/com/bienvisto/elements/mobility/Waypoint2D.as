package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.aggregate.Aggregate;
	
	/**
	 * Waypoint.as
	 * 
	 * Stores the position and direction of some node at some point in time
	 *
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public class Waypoint2D extends Aggregate
	{
		public function Waypoint2D(time:uint, position:Vector2D, direction:Vector2D)
		{
			super(time);
			_position = position;
			_direction = direction;
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
		
		/**
		 * @private
		 */ 
		private var _direction:Vector2D;
		
		/**
		 * @readonly direction
		 */ 
		public function get direction():Vector2D
		{
			return _direction;
		}
	}
}