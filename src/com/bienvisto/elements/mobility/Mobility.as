package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.NodeContainer;
	
	public final class Mobility extends TraceSource implements ISimulationObject
	{
		public function Mobility(nodes:NodeContainer, model:IMobilityModel)
		{
			super("Course Changed", "cc");
			this.nodes = nodes;
			_model = model;
		}
		
		/**
		 * @private
		 */ 
		private var _model:IMobilityModel;
		
		/**
		 * @readonly model
		 */ 
		public function get model():IMobilityModel
		{
			return _model;
		}
		
		/**
		 * @private
		 */ 
		private var nodes:NodeContainer;
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):void
		{
			
			// FORMAT: cc <node id> <time> <pos_x> <pos_y> <vel_x> <vel_y>
			var id:int = int(params[0]);
			var point:Waypoint = model.getWaypoint(params);
			nodes.getNode(id).addWaypoint(point);
			
		}
		
		/**
		 * On time update
		 * 
		 * @parm elapsed
		 */ 
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
	}
}