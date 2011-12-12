package com.bienvisto.elements.network
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.elements.mobility.IMobilityModel;
	import com.bienvisto.elements.mobility.Waypoint;
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
			_waypoints = new AggregateCollection();
			_transmissions = new AggregateCollection();
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
		 * @private
		 */ 
		private var _transmissions:AggregateCollection;
		
		/**
		 * @readonly transmissions
		 */ 
		public function get transmissions():Vector.<Aggregate>
		{
			return _transmissions.items;
		}
		
		/**
		 * @readonly totalTransmissions
		 */ 
		public function get transmissionsTotal():uint
		{	
			return _transmissions.getTotal(_time);
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
		 * @private
		 */ 
		private var _routingTable:RoutingTable;
		
		/**
		 * @readwrite routingTable
		 */ 
		public function get routingTable():RoutingTable
		{
			return _routingTable;
		}
		
		public function set routingTable(value:RoutingTable):void
		{
			_routingTable = value;
		}
		
		/**
		 * @private
		 */
		private var _mobilityModel:IMobilityModel;
		
		/**
		 * @readwrite mobilityModel
		 */ 
		public function get mobilityModel():IMobilityModel
		{
			return _mobilityModel;
		}
		
		public function set mobilityModel(value:IMobilityModel):void
		{
			_mobilityModel = value;
		}
		
		
		/**
		 * @private
		 */
		private var _waypoints:AggregateCollection;
		
		/**
		 * @rea
		 */ 
		public function get waypoints():Vector.<Aggregate>
		{
			return _waypoints.items;
		}

		
		/**
		 * Add transmission
		 * 
		 * @param item
		 */ 
		public function addTransmission(item:Transmission):void
		{
			_transmissions.add(item);
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
		 * Add waypoint
		 * 
		 * @param point
		 */ 
		public function addWaypoint(point:Waypoint):void
		{
			_waypoints.add(point);
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