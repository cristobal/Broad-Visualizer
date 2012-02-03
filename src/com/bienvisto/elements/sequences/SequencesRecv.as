package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * SequecesRecv.as
	 * 	
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesRecv extends TraceSource implements ISimulationObject
	{
		public function SequencesRecv(parent:SequencesContainer)
		{
			super("SequencesRecv", "sr");
			
			this.parent		   = parent;
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
		private var stats:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var drops:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var first:Boolean = true;
		
		/**
		 * @private
		 */ 
		private var _destNode:Node;
		
		/**
		 * @readonly destNode
		 */ 
		public function get destNode():Node
		{
			return _destNode;
		}
		
		/**
		 * @private
		 */ 
		private var _lastSeqNum:int;
		
		/**
		 * @readonly lastSeqNum
		 */ 
		public function get lastSeqNum():int
		{
			return _lastSeqNum;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var seqNum:uint = uint(params[2]);
			
			if (!(id in collections)) {
				collections[id] = new SequencesCollection();
				stats[id]	    = new AggregateCollection();
				drops[id]		= new AggregateCollection();
			}
			
			
			var sequence:Sequence = new Sequence(time, seqNum);
			SequencesCollection(collections[id]).add(sequence);
			
			updateDrops(id, sequence);
			updateStats(id, sequence);
			
			if (first) {
				_destNode = parent.nodeContainer.getNode(id);
				
				dispatchEvent(new Event(Event.CHANGE));
				first = false;
			}
			
			return time;
		}
		
		/**
		 * Update drops
		 * 
		 * @param id
		 * @param sequence
		 */ 
		private function updateDrops(id:int, sequence:Sequence):void
		{
			var seqNum:int = sequence.seqNum;
			var time:uint  = sequence.time;
			
			if (seqNum in map) {
				var collection:AggregateCollection = AggregateCollection(drops[id]);
				collection.add(sequence);
			}
			
		}
		
		/**
		 * Update state
		 * 
		 * @param sequence
		 */ 
		private function updateStats(id:int, sequence:Sequence):void
		{
			var seqNum:int = sequence.seqNum;
			var time:uint  = sequence.time;
			if (!(seqNum in map)) {
				map[seqNum] = sequence;
				
				var sent:Sequence       = parent.sent.findSequenceBySeqNum(seqNum);
				if (sent) {
					var collection:AggregateCollection = AggregateCollection(stats[id]);
					
					var value:int = time - sent.time;
					var total:int = collection.size + 1;
					
					var item:SequencesStats = SequencesStats(collection.last()); 
					if (item) {
						value += item.value;
					}
					item = new SequencesStats(time, value, total);
					collection.add(item);
				}
				
				_lastSeqNum  = seqNum;	
			}
		}
		
		/**
		 * Sample dest total
		 * 
		 * @param time
		 */	
		public function sampleDestTotal(time:uint):int
		{
			if (!destNode) {
				return 0;
			}
			
			return sampleTotal(destNode, time) - sampleDrops(destNode, time);
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
		 * Sample dest total
		 * 
		 * @param time
		 */	
		public function sampleDestDrops(time:uint):int
		{
			if (!destNode) {
				return 0;
			}
			
			return sampleDrops(destNode, time);
		}
		
		/**
		 * Sample drops
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleDrops(node:Node, time:int):int
		{
			var id:int = node.id;
			if (!(id in drops)) {
				return 0;
			}
			
			return AggregateCollection(drops[id]).sampleTotal(time);
		}
		
		/**
		 * Samplerate
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
			var collection:SequencesCollection = SequencesCollection(collections[id]);
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
		
		/**
		 * Sample dest  
		 */
		public function sampleDestTime(time:uint):uint
		{
			var id:int = destNode ? destNode.id : -1;
			if (!(id in stats)) {
				return 0;	
			}
			
			var item:SequencesStats = SequencesStats(AggregateCollection(stats[id]).findNearest(time));
			return item ? uint(item.avg) : 0;
		}
		
		/**
		 * Sample dest  
		 */
		public function sampleDestLastSeqNum(time:uint):int
		{
			var id:int = destNode ? destNode.id : -1;
			if (!(id in collections)) {
				return -1;	
			}
			
			var item:Sequence = Sequence(SequencesCollection(collections[id]).findNearest(time));
			return item ? item.seqNum : -1;
		}

		/**
		 * Find seq num
		 * 
		 * @param seqNum
		 */ 
		public function findSequenceBySeqNum(seqNum:int):Sequence
		{
			return Sequence(map[seqNum]);
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