package elements.topology
{

	import core.Vector2D;

	import elements.KeypointBase;


	/**
	 * Stores the position and direction of some node at some point in time
	 */
	public class Waypoint2D extends KeypointBase
	{

		/**
		 * Position of the waypoint
		 */
		protected var position_:Vector2D;

		/**
		 * Direction of the waypoint
		 */
		protected var direction_:Vector2D;


		/**
		 * Constructor of the class
		 *
		 * @param pos Position of the waypoint
		 * @param dir Direction of the waypoint, in meters/s
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node passed through this waypoint
		 * @param node Id of the node associated to this keypoint
		 */
		public function Waypoint2D(pos:Vector2D, dir:Vector2D, ms:uint, node:int)
		{
			super(ms, node);
			
			position_ = new Vector2D(pos.x, pos.y);
			direction_ = new Vector2D(dir.x, dir.y);
		}


		/**
		 * Position of the waypoint
		 */
		public function get position():Vector2D { return position_; }

		/**
		 * Direction of the waypoint
		 */
		public function get direction():Vector2D { return direction_; }



	}
}
