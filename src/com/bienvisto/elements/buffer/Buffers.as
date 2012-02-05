package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
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
			
			if (!(id in collections)) {
				collections[id] = new BufferCollection();
			}
			
			BufferCollection(collections[id]).add(
				new Buffer(time, size)
			);
			
			return time;
		}
		
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
			
			return Buffer(BufferCollection(collections[id]).findNearest(time));;
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
			
			return BufferCollection(collections[id]).sampleTotal(time);
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

		
	}
}