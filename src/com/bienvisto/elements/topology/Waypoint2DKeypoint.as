package com.bienvisto.elements.topology
{
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.elements.KeypointBase;


	/**
	 * Stores the position and direction of some node at some point in time
	 */
	public class Waypoint2DKeypoint extends KeypointBase
	{



		/**
		 * Constructor of the class
		 *
		 * @param pos Position of the waypoint
		 * @param dir Direction of the waypoint, in meter/s
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node passed through this waypoint
		 * @param node Id of the node associated to this keypoint
		 */
		public function Waypoint2DKeypoint(pos:Vector2D, dir:Vector2D, ms:uint, node:int)
		{
			super(ms, node);
			
			_position = pos.clone();
			_direction = dir.clone(); 
		}

		/**
		 * @private
		 * 	Position of the waypoint
		 */
		private var _position:Vector2D;
		
		/**
		 * Direction of the waypoint
		 */
		protected var _direction:Vector2D;
		
		/**
		 * Position of the waypoint
		 */
		public function get position():Vector2D { 
			return _position; 
		}

		/**
		 * Direction of the waypoint
		 */
		public function get direction():Vector2D { 
			return _direction; 
		}



	}
}
