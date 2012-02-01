package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * SequencesSent.as
	 * 	Class responsible of parsing "sequences sent" block of the trace.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesSent extends TraceSource implements ISimulationObject
	{
		public function SequencesSent(nodeContainer:NodeContainer)
		{
			super("SequencesSent", "ss");
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
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
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var seqNum:uint = uint(params[2]);
			var sequence:Sequence = new Sequence(time, seqNum);
			
			var collection:SequenceCollection = getCollection(id);
			collection.add(sequence);
			
			return time;
		}
		
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleTotal(node:Node, time:int):int
		{
			var collection:SequenceCollection = getCollection(node.id);
			var total:int = collection.sampleTotal(time);
			
			return total;
		}
		
		
		/**
		 * Get collection
		 */ 
		private function getCollection(id:int):SequenceCollection
		{
			var collection:SequenceCollection;
			if (!(id in collections)) {
				collection = new SequenceCollection();
				collections[id] = collection;
			}
			else {
				collection = SequenceCollection(collections[id]);
			}
			
			return collection;
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