package com.bienvisto.elements
{
	// TODO: Add some memoization for total like for a set of interval of time to store.
	
	/**
	 * Node.as
	 * 	The common real node reference to be used by sub nodes.
	 *  
	 * @author Cristobal Dabed
	 * @version {{VERSION_NUMBER}}
	 */ 
	public class Node
	{
		/**
		 * Constructor
		 */ 
		public function Node(id:int)
		{
			_id = id;
			_transmissions = new Vector.<Packet>;
			_receptions = new Vector.<Packet>;
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
		private var _role:String = "undefined";
		
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
		private var _address:String;
		
		/**
		 * @readwrite address
		 */ 
		public function get address():String
		{
			return _address;
		}
	 
		public function set address(value:String):void
		{
			_address = value;
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
		 * @private
		 */ 
		private var _transmissions:Vector.<Packet> = null;
		
		/**
		 * @readonly transmissions
		 */ 
		public function get transmissions():Vector.<Packet>
		{
			return _transmissions.concat(); // return shallow copy
		}
		
		/**
		 * @readonly totalTransmissions
		 */ 
		public function get transmissionsTotal():uint
		{	
			return calculateTotalPackets(_transmissions, _time);
		}
		
		/**
		 * @private
		 */ 
		private var _receptions:Vector.<Packet> = null;
		
		/**
		 * @readonly receptions
		 */ 
		public function get receptions():Vector.<Packet>
		{
			return _receptions.concat(); // return shallow copy
		}
		
		/**
		 * @readonly receptionsTotal
		 */ 
		public function get receptionsTotal():uint
		{
			return calculateTotalPackets(_receptions, _time);
		}
		
		/**
		 * @private
		 */ 
		private var _drops:Vector.<Packet> = null;
		
		/**
		 * @readonly drops
		 */ 
		public function get drops():Vector.<Packet>
		{
			return _drops.concat(); // return shallow copy
		}
		
		/**
		 * @readonly dropsTotal
		 */ 
		public function get dropsTotal():uint
		{
			
			return calculateTotalPackets(_drops, _time);
		}

		
		/**
		 * Add transmission
		 * 
		 * @param time
		 * @param to
		 */ 
		public function addTransmission(time:uint, to:uint, size:uint):void
		{
			_transmissions.push( new Packet(time, id, to, size) );
		}
			
		/**
		 * Add reception
		 * 
		 * @param time
		 * @param from
		 */ 
		public function addReception(time:uint, from:uint, size:uint):void
		{
			_receptions.push( new Packet(time, from, id, size) );
		}
		
		/**
		 * Add drop
		 * 
		 * @param time
		 */ 
		public function addDrop(time:uint):void
		{
			_drops.push( new Packet(time, 0, id, 0) );
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
	}
}