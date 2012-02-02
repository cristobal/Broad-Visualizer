package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * Mobility.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Mobility extends TraceSource implements ISimulationObject
	{
		public function Mobility(nodeContainer:NodeContainer)
		{
			super("Course Changed", "cc");
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 * 	A references to the node container for all the current nodes  present in the simulation
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 * 
		 */ 
		private var collections:Dictionary = new Dictionary();
		
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
				collections[id] = new MobilityCollection();
			}
			
			
			MobilityCollection(collections[id]).add(
				new Waypoint2D(time, pos, dir)
			);
			
			return time;
		}
		
		/**
		 * On time update
		 * 
		 * @parm elapsed
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
		 * Find waypoint
		 * 
		 * @param id
		 * @param time
		 */ 
		public function findWaypoint(node:Node, time:uint):Waypoint2D
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return Waypoint2D(MobilityCollection(collections[id]).findNearest(time));
		}
	}
}