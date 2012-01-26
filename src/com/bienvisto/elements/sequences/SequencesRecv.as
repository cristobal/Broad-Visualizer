package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	public final class SequencesRecv extends TraceSource implements ISimulationObject
	{
		public function SequencesRecv(nodeContainer:NodeContainer)
		{
			super("SequencesRecv", "sr");
			
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
			
			var collection:SequenceCollection;
			if (!(id in collections)) {
				collection = new SequenceCollection();
				collections[id] = collection;
			}
			else {
				collection = SequenceCollection(collections[id]);
			}
			
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
			var id:int = node.id;
			var total:int = 0;
			
			if 	(id in collections) {
				var collection:SequenceCollection = SequenceCollection(collections[id]);
				total = collection.sampleTotal(time);
			}
			
			return total;
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