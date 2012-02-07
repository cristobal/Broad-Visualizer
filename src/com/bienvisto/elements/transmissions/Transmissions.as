package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.core.network.node.NodeContainer;
	import com.bienvisto.core.network.packet.Packet;
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.utils.Dictionary;
	
	/**
	 * Transmissions.as
	 * 	A trace source subclass which parses all the trace sources 
	 *  for the mac transmisions event type in the simulations.
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public final class Transmissions extends TraceSource implements ISimulationObject, IAggregateProvider
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * 
		 * @param nodeContainer
		 */
		public function Transmissions(nodeContainer:NodeContainer)
		{
			super("Mac Transmissions", "mt"); // mac transmissions
			this.nodeContainer = nodeContainer;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	A references to the node container for all the current nodes  present in the simulation
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private  
		 *  A collection of AggregateCollection that store the packet aggregates sent from each node
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A hash map to lookup sampled items that have already been calculated
		 */ 
		private var samples:Dictionary	   = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var complete:Boolean = false;
		
		
		//--------------------------------------------------------------------------
		//
		//  ISimulation Object Implementation
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On time update
		 * 
		 * @param elapsed
		 */ 
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
		
		/**
		 * Set duration
		 * 
		 * @param duration
		 */
		public function setDuration(duration:uint):void
		{
			
		}
		
		/**
		 * Reset
		 */ 
		public function reset():void
		{
			collections = new Dictionary();
			samples	    = new Dictionary();
			complete	= false;
		}

		
		//--------------------------------------------------------------------------
		//
		//  Override TraceSource Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @override
		 */ 
		override public function onComplete():void
		{
			complete = true;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// format: mt <node id> <time> <packet_size> <next_hop_id> 
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var size:Number = uint(params[2]);
			var destination:int = int(params[3]);
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
				samples[id]		= new Dictionary();
			}
			
			AggregateCollection(collections[id]).add(
				new Packet(time, id, destination, size)
			);
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Find nearest
		 * 
		 * @param node
		 * @param time
		 */ 
		public function findNearest(node:Node, time:uint):Aggregate
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return AggregateCollection(collections[id]).findNearest(time);
		}
		
		/**
		 * Sample packets
		 * 
		 * @param node
		 * @param time
		 * @param windowSize
		 */ 
		public function samplePackets(node:Node, time:uint, windowSize:uint):Vector.<Packet>
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			var key:String = String(time) + "-" + String(windowSize);
			if (key in samples[id]) {
				return Vector.<Packet>(samples[id][key]);
			}
			
			var packets:Vector.<Packet> = Vector.<Packet>(AggregateCollection(collections[id]).sampleItems(time, windowSize));
			
			// only cache if parsing complete
			if (complete) {
				samples[key] = packets;
			}
			
			return packets;
		}
	
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleTotal(node:Node, time:uint):int
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return 0;
			}
			
			return AggregateCollection(collections[id]).sampleTotal(time);
		}
		
		/**
		 * Sample rate
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleRate(node:Node, time:int):int
		{
			
			var id:int = node.id;
			if (!(id in collections)) {
				return 0;	
			}
			
			var rate:int = 0;
			var collection:AggregateCollection = AggregateCollection(collections[id]);
			var windowSize:int = 1000;
			var up:int = time - (time % windowSize);
			if (up > 0) {	
				var lb:int = time - windowSize;	
				var start:int = collection.findNearestKey(lb);
				var end:int   = collection.findNearestKey(up);
				
				rate = end - start;
			}
			
			return rate;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  IAggregateDataProvider Implementation
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Get items
		 * 
		 * @param node
		 */ 
		public function getItems(node:Node):Vector.<Aggregate>
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return AggregateCollection(collections[id]).items;
		}
	}
}