package com.bienvisto.elements.topology
{

	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.NodeBase;
	import com.bienvisto.util.Tools;
	
	import flash.events.Event;
	
	import spark.effects.AnimateColor;



	/**
	 * Represents a node in the visualization and stores its movement along a
	 * number of Waypoints
	 */
	public class TopologyNode extends NodeBase
	{

		/**
		 * Index pointing to the active waypoint in the waypoints list
		 * Since the stepTo function is no longer in use, this variable is not used
		 * However, it could be still useful (see comments at stepTo function)
		 */
		protected var _waypoint:int;
		/**
		 * Whether the node has reached the end of its path or not
		 */
		protected var _finished:Boolean = false;
		/**
		 * Whether the node is selected or not
		 */
		protected var _selected:Boolean = false;
		/**
		 * Color used to represent the node
		 */
		public var _color:uint;
		
		/**
		 * Animation that changes the color of the node when it is highlighted
		 */
		protected var _animation:AnimateColor;



		/**
		 * Constructor of the class
		 */
		public function TopologyNode(id:int, node:Node=null)
		{
			super(id, node);
			
			_color = 0x555555;
			_animation = new AnimateColor(this);
			_animation.duration = 400;
			_animation.colorFrom = 0xFFCC00;
			_animation.colorTo = _color;
			_animation.colorPropertyName = "color";
			//animation_.addEventListener(EffectEvent.EFFECT_END, effectEnded);
			
			_waypoint = 0; // The simulation starts at the first waypoint
			_direction = new Vector2D(0, 0);
			updateGraphics();
		}
		
		/**
		 * @protected
		 */ 
		protected var _direction:Vector2D;
		
		/**
		 * @readonly direction
		 */ 
		public function get direction():Vector2D
		{
			return _direction;
		}
		
		/**
		 * Adds a waypoint at the end of the path.
		 * <strong>NOTE:</strong> Order of added waypoints is important. Waypoints
		 * should be added in order according to the moment of occurrence
		 *
		 * @param position The position of the node after "ms" milliseconds
		 * @param direction The direction of the node after "ms" milliseconds
		 * @param ms The time elapsed, in milliseconds, since the beginning of the
		 * simulation
		 */
		public function addWaypoint(position:Vector2D, direction:Vector2D, ms:uint):void
		{
			// If this is the first node added, we move it to the beginning of the path
			if (keypoints_.length == 0)
			{
				this.x = position.x;
				this.y = position.y;
			}

			keypoints_.push(new Waypoint2DKeypoint(position, direction, ms, id_));
		}


		/**
		 * Moves the node to where it was in the simulation at the moment passed as 
		 * parameter
		 *
		 * @param millisecondsTotal Milliseconds since the beginning of the
		 * simulation
		 */
		public function goTo(millisecondsTotal:uint):void
		{
			var waypoint:Waypoint2DKeypoint; // Active waypoint
			var w:int = 0;
			
			// Search for the waypoint corresponding to millisecondsTotal
			var min:int = 0;
			var max:int = keypoints_.length-1;
			var mid:int;
			do
			{
				mid = min + ( (max - min) / 2 );
				if ( millisecondsTotal > keypoints_[mid].milliseconds )
					min = mid + 1;
				else
					max = mid - 1;
			} while(mid < keypoints_.length-1 && max >= min &&
					(keypoints_[mid].milliseconds > millisecondsTotal || 
					keypoints_[mid+1].milliseconds <= millisecondsTotal));
			
			waypoint = keypoints_[mid] as Waypoint2DKeypoint;
		
			// Calculate the distance in milliseconds between the waypoint and the
			// instant to visualize
			var millisecondsElapsed:int =
				millisecondsTotal - waypoint.milliseconds;
			
			// We position the node in the waypoint and we move it in its direction
			// according to the distance between the waypoint and the time 
			// to visualized
			x = waypoint.position.x
				+ (waypoint.direction.x/1000)*millisecondsElapsed;
			y = waypoint.position.y
				+ (waypoint.direction.y/1000)*millisecondsElapsed;
			
			_direction.x = waypoint.direction.x;
			_direction.y = waypoint.direction.y;
		}


		/**
		 * Highlights this node for half a second
		 *
		 * @param color Color used to highlight the node
		 */
		public function highlight(color:uint = 0xFFCC00):void
		{
			
			_animation.colorFrom = color;
			
			_animation.stop();
			_animation.play();
		}


		/**
		 * Updates the graphics for this node. In this case,  it draws a 
		 * coloured circle. If the node is selected, the circle will be
		 * rendered with a red stroke
		 */
		protected function updateGraphics():void
		{
			graphics.clear(); // Clear the graphics layer
			
			graphics.beginFill(_color);
			if (_selected) graphics.lineStyle(3, 0xff6622);
			graphics.drawCircle(0, 0, 10);
			graphics.endFill();
		}


		public function get selected():Boolean { return _selected; }
		public function set selected(s:Boolean):void { _selected = s; updateGraphics(); }

		public function get position():Vector2D { return new Vector2D(x,y); }
		
		public function get color():uint { return _color; }
		public function set color(c:uint):void { _color = c; updateGraphics(); }


		/*
		* This function has been replaced by goTo, which permits jumps in time; this
		* function requires that the node goes through all waypoints in order.
		* However, it still could be useful if there are performance problems since
		* it is faster than goTo. In such case, this function should be called 
		* always except when there is a jump in time or if the visualization is 
		* being played backwards
		public function stepTo(millisecondsTotal:uint):void
		{
			if (finished_)
				return;

			// Check if it's time to change to the next waypoint
			if (millisecondsTotal >= waypoints_[waypoint_].milliseconds)
			{
				waypoint_++;
			
				// Check if this is the last waypoint
				if (waypoint_ >= waypoints_.length)
				{
					finished_ = true;
					return;
				}
			
				this.x = waypoints_[waypoint_].position.x;
				this.y = waypoints_[waypoint_].position.y;
			}

			// Calculate how many milliseconds have passed since the last call to 
			// this function so that we can know how much to move the node
			var millisecondsElapsed:uint = millisecondsTotal - lastUpdate_;
		
			x += (waypoints_[waypoint_].direction.x/1000)*millisecondsElapsed;
			y += (waypoints_[waypoint_].direction.y/1000)*millisecondsElapsed;
		
			// Finally we update the lastUpdated var
			lastUpdate_ = millisecondsTotal;
		}
	*/

	}

}
