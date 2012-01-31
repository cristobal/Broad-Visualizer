package com.bienvisto.elements.topology
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.elements.network.graph.Graph;
	
	/**
	 * TopologySet.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class TopologySet extends Aggregate
	{
		public function TopologySet(time:uint, id:int, tuples:Vector.<TopologyTuple>)
		{
			super(time);
			
			_id     = id;
			_tuples = tuples;
			if (!_tuples) {
				_tuples = new Vector.<TopologyTuple>();
			}
		}
		
		/**
		 * @private
		 */ 
		private var _id:int;
		
		/**
		 * @readonly tuple
		 */ 
		public function get id():int
		{
			return _id;
		}
		
		/**
		 * @private 
		 */ 
		private var _tuples:Vector.<TopologyTuple>;
		
		/**
		 * @readonly tuples
		 */ 
		public function get tuples():Vector.<TopologyTuple>
		{
			return _tuples;
		}
		
		/**
		 * @private
		 */ 
		private var _graph:Graph;
		
		/**
		 * @readonly graph
		 */ 
		public function get graph():Graph
		{
			if (!_graph) {
				_graph = resolveGraph();
			}
			
			return _graph;
		}
		
		/**
		 * Resolve graph
		 */ 
		private function resolveGraph():Graph
		{
			var graph:Graph = new Graph();
			
			var tuple:TopologyTuple;
			for (var i:int = 0, l:int = _tuples.length; i < l; i++) {
				tuple = _tuples[i];
				
				// Assume direct edge from this node id to lastID trough for the destination how many actual 
				graph.addEdge(id, tuple.lastID, 1);
				
				// Add another link from the lastID to the destination how many actual hops there are to the destination no idea
				graph.addEdge(tuple.lastID, tuple.destID, 1);
			}
			return graph;
		}
		
	}
}