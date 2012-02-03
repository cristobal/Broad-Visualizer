package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * SequencesInserted.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesInserted extends TraceSource implements ISimulationObject
	{
		public function SequencesInserted(parent:SequencesContainer)
		{
			super("Sequences Inserted", "si");
			this.parent = parent;
		}
		
		/**
		 * @private
		 */ 
		private var parent:SequencesContainer;
		
		/**
		 * @private
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var map:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var removed:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// Format: sf <id> <time> <seqNum>
			var id:int = int(params[0]);
			var time:int = uint(params[1]);
			var seqNum:int = int(params[2]); 
			
			if (!(id in collections)) {
				collections[id] = new SequencesCollection();
				removed[id]     = new AggregateCollection();
			}
			
			var sequence:Sequence = new Sequence(time, seqNum);
			SequencesCollection(collections[id]).add(sequence);
			
			 
			if (!(seqNum in map)) {
				map[seqNum] = sequence;
			}

			
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
			if (!(id in collections)) {
				return 0;
			}
			
			return SequencesCollection(collections[id]).sampleTotal(time);
		}
		
		
		/**
		 * Buffer size
		 * 
		 * @param node
		 * @param time
		 */ 
		public function bufferSize(node:Node, time:int):int
		{
			var id:int = node.id;
			if (!(id in removed)) {
				return 0;
			}
			
			var item:SequencesStats  = SequencesStats(AggregateCollection(removed[id]).findNearest(time))
			
			return  item ? item.value : 0;
			
		}
		
		
		/**
		 * Remove sequence
		 * 
		 * @param node
		 * @param sequence
		 * @param time
		 */ 
		public function removeSequence(node:Node, sequence:Sequence):void
		{
			var id:int = node.id;
			var seqNum:int = sequence.seqNum;
			var time:uint  = sequence.time;
			if (seqNum in map) {
				
				var sequences:SequencesCollection  = SequencesCollection(collections[id]);
				var collection:AggregateCollection = AggregateCollection(removed[id]);
				
				var value:int = sequences.sampleTotal(time);
				var total:int = collection.size + 1;
				
				var item:SequencesStats = SequencesStats(collection.last()); 
				if (item) {
					value = item.value;
				}
				value--;
				
				if (value < 0) {
					value = 0;
				}
				
				item = new SequencesStats(time, value, total);
				collection.add(item);
			}
		}
		
	
		
		public function onTimeUpdate(elapsed:uint):void
		{
		}
		
		public function setDuration(duration:uint):void
		{
		}
	}
}