package com.bienvisto.elements.network.packet
{
	import com.bienvisto.elements.network.node.Node;

	/**
	 * PacketStats.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class PacketStats
	{
		public function PacketStats(node:Node, time:uint, totalOwn:int, totalOther:int)
		{
			_node 		= node;
			_time 		= time;
			_totalOwn 	= totalOwn;
			_totalOther = totalOther;
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
		private var _time:uint;
		
		/**
		 * @readonly time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		/**
		 * @private
		 */ 
		private var _totalOwn:int;
		
		/**
		 * @readonly totalOwn
		 */ 
		public function get totalOwn():int
		{
			return _totalOwn;
		}
		
		/**
		 * @private
		 */ 
		private var _totalOther:int
		
		/**
		 * @readonly totalOther
		 */ 
		public function get totalOther():int
		{
			return _totalOther;
		}
	}
}