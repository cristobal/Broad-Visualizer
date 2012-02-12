package com.broad.core.aggregate
{
	/**
	 * AggregateKey.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class AggregateKey
	{
		public function AggregateKey(key:int, time:uint, prev:AggregateKey = null)
		{
			_key = key;
			_time = time;
			_prev = prev;
		}
		
		/**
		 * @readonly key
		 */ 
		private var _key:int;
		
		/**
		 * @private
		 */ 
		public function get key():int
		{
			return _key;
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
		private var _prev:AggregateKey;
		
		/**
		 * @private
		 */ 
		public function get prev():AggregateKey
		{
			return _prev;	
		}
		
	}
}