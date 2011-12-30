package com.bienvisto.elements.network
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.elements.mobility.Waypoint2D;
	import com.bienvisto.elements.routing.RoutingTable;
	import com.bienvisto.elements.transmissions.Transmission;
	import com.bienvisto.util.sprintf;

	// TODO: Set current point in time waypoint position…
	// TODO: Add some memoization for total like for a set of interval of time to store.
	
	/**
	 * Node.as
	 * 	The common real node reference to be used by sub nodes.
	 *  
	 * @author Cristobal Dabed
	 */ 
	public class Node
	{
		/**
		 * Constructor
		 */ 
		public function Node(id:int)
		{
			_id = id;
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
		 * @readwrite time
		 */ 
		public function get time():uint 
		{
			return _time;
		}
		
		public function set time(value:uint):void
		{
			_time = value;
		}
			
		
		/**
		 * @private
		 */ 
		private var _role:String = "–";
		
		/**
		 * @readwrite role
		 */ 
		public function get role():String
		{
			return _role;
		}
		
		public function set role(value:String):void
		{
			_role = value;
		}
		
		/**
		 * @private
		 */ 
		private var _ipv4Address:String = "00.00.00.00";
		
		/**
		 * @readwrite address
		 */ 
		public function get ipv4Address():String
		{
			return _ipv4Address;
		}
	 
		public function set ipv4Address(value:String):void
		{
			_ipv4Address = value;
		}
		
		/**
		 * @private
		 */ 
		private var _macAddress:String = "00:00:00:00:00:00";
		
		/**
		 * @readwrite macAddress
		 */ 
		public function get macAddress():String
		{
			return _macAddress;
		}
		
		public function set macAddress(value:String):void
		{
			_macAddress = value;
		}
		
		/**
		 * @private
		 */ 
		private var _bufferSize:uint;
		
		/**
		 * @readwrite buffersize
		 */ 
		public function set bufferSize(value:uint):void
		{
			_bufferSize = value;
		}
		
		public function get bufferSize():uint
		{
			return _bufferSize;
		}
		
		/**
		 * Calculate total packets
		 * 	The order of the packets in the vector must linear in time.
		 *  
		 * @param packets The vector of packets to count
		 * @param time 	  Until the time to count
		 */ 
		private function calculateTotalPackets(packets:Vector.<Packet>, time:uint):uint 
		{
			var total:uint;	
			for each (var packet:Packet in packets) {
				if (packet.time > time) {
					break; // break when the packet time is more.
				}
				total++;
			}
			
			return total;
		}
		
		/**
		 * To String
		 */ 
		public function toString():String
		{
			return sprintf('{id: "%d", ipv4Address: "%s", macAddress: "%s", role: "%s"}', id, ipv4Address, macAddress, role);
		}
	}
}