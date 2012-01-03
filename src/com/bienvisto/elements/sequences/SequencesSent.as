package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	
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
		override public function update(params:Vector.<String>):void
		{
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var seqNum:uint = uint(params[2]);
			var sequence:Sequence = new Sequence(time, seqNum);
			
			var collection:SequenceCollection;
			if (!(id in collections)) {
				collection = new SequenceCollection();
				collections[id] = collection;
			}
			else {
				collection = SequenceCollection(collections[id]);
			}
			
			collection.add(sequence);
		}
		
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleTotal(node:Node, time:int):int
		{
			var id:int = node.id;
			var total:int = 0;
			
			if 	(id in collections) {
				var collection:SequenceCollection = SequenceCollection(collections[id]);
				total = collection.sampleTotal(time);
			}
			
			return total;
		}
		
		public function onTimeUpdate(elapsed:uint):void
		{
		}
		
	}
}