package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.core.network.node.NodeContainer;
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.utils.Dictionary;
	
	/**
	 * Mobility.as
	 *  When a node changes course in the simulation a new waypoint is emited and added to the tracesource.
	 *  These waypoints are collected here in a Mobility2D aggregate collection for each node.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Mobility extends TraceSource implements ISimulationObject
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */ 
		public function Mobility(nodeContainer:NodeContainer)
		{
			super("Course Changed", "cc");
			this.nodeContainer = nodeContainer;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	A reference to the node container for all the current nodes  present in the simulation
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 *  A collection of AggregateCollection that stores WayPoint2D aggregates
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var cache:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	The last point in time at which we sampled a waypoint
		 */ 
		private var delta:uint = uint.MAX_VALUE;
		
		/**
		 * @private
		 */ 
		private var complete:Boolean = false;
		
		
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
			collections = new Dictionary();
			cache		= new Dictionary();
			delta		= uint.MAX_VALUE;
			complete    = false;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Override TraceSource Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function onComplete():void
		{
			complete = true;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// FORMAT: cc <node id> <time> <pos_x> <pos_y> <vel_x> <vel_y>
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var pos:Vector2D = new Vector2D(Number(params[2]), Number(params[3]));
			var dir:Vector2D = new Vector2D(Number(params[4]), Number(params[5]));
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
				cache[id]	    = new Dictionary();
			}
			
			AggregateCollection(collections[id]).add(
				new Waypoint2D(time, pos, dir)
			);
			delta = time;
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Find waypoint
		 * 
		 * @param node
		 * @param time
		 */ 
		public function findWaypoint(node:Node, time:uint):Waypoint2D
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			if (time in cache[id]) {
				return Waypoint2D(cache[id][time]);
			}
			
			var waypoint:Waypoint2D = Waypoint2D(AggregateCollection(collections[id]).findNearest(time));
			// only cache after parsing completed or if the time is before the last sampled value
			if (complete || time < delta) {
				cache[id][time] = waypoint;
			}
			
			return waypoint;
		}
	}
}