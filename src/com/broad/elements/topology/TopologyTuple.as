package com.broad.elements.topology
{
	/**
	 * TopologyTuple.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class TopologyTuple
	{
		public function TopologyTuple(destID:int, lastID:int, seqNum:int, expTime:uint)
		{
			_destID = destID;
			_lastID = lastID;
			_seqNum = seqNum;
			_expTime = expTime;
		}

		/**
		 * @private
		 */ 
		private var _destID:int;
		
		/**
		 * @readonly destID
		 */ 
		public function get destID():int
		{
			return _destID;
		}
		
		/**
		 * @private
		 */ 
		private var _lastID:int;
		
		/**
		 * @readonly lastID
		 */ 
		public function get lastID():int
		{
			return _lastID;
		}
		
		/**
		 * @private
		 */ 
		private var _seqNum:int;
		
		/**
		 * @readonly seqNum
		 */ 
		public function get seqNum():int
		{
			return _seqNum;
		}
		
		/**
		 * @private
		 */ 
		private var _expTime:uint;
		
		/**
		 * @readonly expTime
		 */ 
		public function get expTime():uint
		{
			return _expTime;
		}
	}
}