package com.bienvisto.elements.routing
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.elements.network.Node;
	
	/**
	 * RoutingTable.as
	 * 
	 * 	Stores the routing table of a node at certain time in the simulation
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public final class RoutingTable extends Aggregate
	{
		public function RoutingTable(time:uint, node:Node, entries:Vector.<RoutingTableEntry>)
		{
			super(time);
			
			_node = node;
			_entries = entries;
			if (!_entries) {
				_entries = new Vector.<RoutingTableEntry>();
			}
		}
		
		/**
		 * @private
		 */ 
		private var _node:Node;
		
		/**
		 * @readonly node
		 */ 
		public function get node():Node
		{
			return _node;
		}
		
		/**
		 * @private
		 */ 
		private var _entries:Vector.<RoutingTableEntry>;
		
		/**
		 * @readonly entries
		 */ 
		public function get entries():Vector.<RoutingTableEntry>
		{
			return _entries;
		}
	}
}