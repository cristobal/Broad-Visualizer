package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.Vector2D;
	
	/**
	 * Waypoint2D.as
	 * 
	 *
	 * Stores the position and direction of some node at some point in time
	 *
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public final class Waypoint2D extends Waypoint
	{
		public function Waypoint2D(time:uint, position:Vector2D, direction:Vector2D)
		{
			super(time, position);
			_direction = direction;
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