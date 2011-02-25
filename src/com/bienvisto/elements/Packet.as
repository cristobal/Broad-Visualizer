package com.bienvisto.elements
{
	/**
	 * Packet.as
	 * 	Represents a basic transmission packet (sent/recv)
	 *  It is readonly since it represents a state in time.
	 * 
	 * @author Cristobal Dabed
	 * @version {{VERSION_NUMBER}}
	 */ 
	public final class Packet
	{
		// TODO: Add support for IPv6 for the moment we are working with IPv4 only.
		// NOTE: Using uint's for the node ids not the address from,to lookup by using the NodeManager.
		//		 Or should we use the string's saving a bit of space…
		
		/**
		 * Constructor
		 */ 
		public function Packet(time:uint, from:uint, to:uint, size:uint)
		{
			_time = time;
			_from = from;
			_to   = to;
			_size = size;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint = 0;
		
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
		private var _from:uint;
		
		/**
		 * @readonly from
		 */ 
		public function get from():uint
		{
			return _from;
		}
		
		/**
		 * @private
		 */ 
		private var _to:uint;
		
		/**
		 * @readonly to
		 */ 
		public function get to():uint
		{
			return _to;
		}
		
		/**
		 * @private
		 */ 
		private var _size:uint;
		
		/**
		 * @readonly size
		 */ 
		public function get size():uint
		{
			return _size;
		}
	}
}