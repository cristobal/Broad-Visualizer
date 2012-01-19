package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * Buffers.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Buffers extends TraceSource implements ISimulationObject
	{
		public function Buffers(nodeContainer:NodeContainer)
		{
			super("Buffer", "be");
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 * 	A references to the node container for all the current nodes  present in the simulation
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// Format: <node id> <time> <new_queue_size>
			var id:int 	  = int(params[0]);
			var time:uint = uint(params[1]);
			var size:uint = int(params[2]);
			
			var buffer:Buffer = new Buffer(time, size);
			
			var collection:BufferCollection;
			if (!(id in collections)) {
				collection = new BufferCollection();
				collections[id] = collection;
			}
			else {
				collection = BufferCollection(collections[id]);
			}
			
			collection.add(buffer);
			
			return time;
		}
		
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
		 * Find buffer
		 * 
		 * @param node
		 * @param time
		 */ 
		public function findBuffer(node:Node, time:uint):Buffer
		{
			var buffer:Buffer;
			var id:int = node.id;
			var collection:BufferCollection;
			
			if (id in collections) {
				collection = BufferCollection(collections[id]);
				buffer = collection.findBuffer(time);
			}
			
			return buffer;
		}
		
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleTotal(node:Node, time:uint):int
		{
			var total:uint = 0;
			var id:int = node.id;
			var collection:BufferCollection;
			
			if (id in collections) {
				collection = BufferCollection(collections[id]);
				total = collection.sampleTotal(time);
			}
			
			return total;
		}
		
	}
}