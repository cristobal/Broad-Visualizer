package com.broad.core.network.packet
{
	import com.broad.core.aggregate.Aggregate;

	/**
	 * Packet.as
	 * 	Represents a basic transmission packet (sent/recv)
	 *  It is readonly since it represents a state in time.
	 * 
	 * @author Cristobal Dabed
	 * @version {{VERSION_NUMBER}}
	 */ 
	public class Packet extends Aggregate
	{
		// TODO: Add support for IPv6 for the moment we are working with IPv4 only.
		// NOTE: Using uint's for the node ids not the address from,to lookup by using the NodeManager.
		//		 Or should we use the string's saving a bit of space…
		
		/**
		 * Constructor
		 */ 
		public function Packet(time:uint, from:uint, to:uint, size:uint)
		{
			super(time);
			_from = from;
			_to   = to;
			_size = size;
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