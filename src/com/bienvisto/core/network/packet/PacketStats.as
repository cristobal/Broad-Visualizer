package com.bienvisto.core.network.packet
{
	import com.bienvisto.core.network.node.Node;

	/**
	 * PacketStats.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class PacketStats
	{
		public function PacketStats(id:int, time:uint, totalOwn:int, totalOther:int)
		{
			_id         = id;
			_time 		= time;
			_totalOwn 	= totalOwn;
			_totalOther = totalOther;
		}
		
		/**
		 * @private
		 */ 
		private var _id:int;
		
		/**
		 * @readonly id
		 */ 
		public function get id():int
		{
			return _id;
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