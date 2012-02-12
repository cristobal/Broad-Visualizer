package com.broad.elements.sequences.sources
{
	import com.broad.core.ISimulationObject;
	import com.broad.core.aggregate.Aggregate;
	import com.broad.core.aggregate.AggregateCollection;
	import com.broad.core.aggregate.IAggregateProvider;
	import com.broad.core.network.node.Node;
	import com.broad.core.network.node.NodeContainer;
	import com.broad.core.parser.TraceSource;
	import com.broad.elements.sequences.Sequence;
	import com.broad.elements.sequences.SequencesContainer;
	import com.broad.elements.sequences.SequencesStats;
	
	import flash.utils.Dictionary;
	
	/**
	 * SequencesInserted.as
	 *  Class responsible of parsing "sequences inserted" from the trace source.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesInserted extends TraceSource implements ISimulationObject, IAggregateProvider
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * 
		 * @param parent
		 */ 
		public function SequencesInserted(parent:SequencesContainer)
		{
			super("Sequences Inserted", "si");
			this.parent = parent;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	The parent sequence container
		 */ 
		private var parent:SequencesContainer;
		
		/**
		 * @private
		 * 	A collection of AggregateCollection that store sequences that have been insertet in a node
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A hash map to lookup sequences that have been inserted by seqNum
		 */ 
		private var map:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A collection of AggregateCollection that store sequences that have been removed from a node.
		 */ 
		private var removed:Dictionary = new Dictionary();
		
		
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
			map		    = new Dictionary();
			removed     = new Dictionary();
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
			// Format: sf <id> <time> <seqNum>
			var id:int = int(params[0]);
			var time:int = uint(params[1]);
			var seqNum:int = int(params[2]); 
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
				removed[id]     = new AggregateCollection();
				map[id]			= new Dictionary();
			}
			
			var sequence:Sequence = new Sequence(time, seqNum);
			AggregateCollection(collections[id]).add(sequence);
			
			 
			if (!(seqNum in map[id])) {
				map[id][seqNum] = sequence;
			}

			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
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
			
			return AggregateCollection(collections[id]).sampleTotal(time);
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
		 * 	This method is specifically called from the SequenceForwarded class.
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
			if (seqNum in map[id]) {
				
				var sequences:AggregateCollection  = AggregateCollection(collections[id]);
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