package com.broad.elements.buffer
{
	import com.broad.core.ISimulationObject;
	import com.broad.core.aggregate.Aggregate;
	import com.broad.core.aggregate.AggregateCollection;
	import com.broad.core.aggregate.IAggregateProvider;
	import com.broad.core.network.node.Node;
	import com.broad.core.network.node.NodeContainer;
	import com.broad.core.parser.TraceSource;
	
	import flash.utils.Dictionary;
	
	/**
	 * Buffers.as
	 * 	Class responsible of parsing "buffer enqueue" from the trace source.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Buffers extends TraceSource implements ISimulationObject, IAggregateProvider
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
		public function Buffers(nodeContainer:NodeContainer)
		{
			super("Buffer", "be");
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
		 * 	A collection of AggregateCollection that stores buffer aggregate for each node
		 */ 
		private var collections:Dictionary = new Dictionary();
		
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
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Override TraceSource Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// Format: <node id> <time> <new_queue_size>
			var id:int 	  = int(params[0]);
			var time:uint = uint(params[1]);
			var size:uint = int(params[2]);
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
			}
			
			AggregateCollection(collections[id]).add(
				new Buffer(time, size)
			);
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Find buffer
		 * 
		 * @param node
		 * @param time
		 */ 
		public function findBuffer(node:Node, time:uint):Buffer
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return Buffer(AggregateCollection(collections[id]).findNearest(time));
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