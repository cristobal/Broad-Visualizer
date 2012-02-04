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
		private var recv:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var recvCache:Dictionary = new Dictionary();
		
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
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var seqNum:uint = uint(params[2]);
			
			if (!(id in collections)) {
				collections[id] = new SequencesCollection();
				recv[id]		= new SequencesCollection();
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
			if (sequence.seqNum in map) {
				AggregateCollection(drops[id]).add(sequence);
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
				
				SequencesCollection(recv[id]).add(sequence);
			}
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
		
		//--------------------------------------------------------------------------
		//
		// Sample total
		//
		//-------------------------------------------------------------------------
		
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
		
		
		//--------------------------------------------------------------------------
		//
		// Sample drops
		//
		//-------------------------------------------------------------------------
		
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
		
		
		//--------------------------------------------------------------------------
		//
		// Sample rate
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample dest rate
		 * 
		 * @param time
		 */ 
		public function sampleDestRate(time:uint):int
		{
			if (!destNode) {
				return 0;
			}
			
			return sampleRate(destNode, time);
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
		
		
		//--------------------------------------------------------------------------
		//
		// Sample dest time
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample dest time
		 * 
		 * @param time  
		 */
		public function sampleDestTime(time:uint):uint
		{
			if (!destNode) {
				return 0;	
			}
			
			return sampleTime(destNode, time);
		}
		
		/**
		 * Sample time
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleTime(node:Node, time:uint):uint
		{
			var id:int = node.id;
			if (!(id in stats)) {
				return 0;
			}
			
			var item:SequencesStats = SequencesStats(AggregateCollection(stats[id]).findNearest(time));
			return item ? uint(item.avg) : 0;
		}
		
		//--------------------------------------------------------------------------
		//
		// Sample dest recv
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample dest recv
		 * 
		 * @param time
		 * @param ordered
		 */ 
		public function sampleDestRecv(time:uint, ordered:Boolean = false):Vector.<Sequence>
		{
			if (!destNode) {
				return null;
			}
			
			return sampleRecv(destNode, time, ordered);
		}
		
		/**
		 * Sample dest recv
		 * 
		 * @param node
		 * @param time
		 * @param ordered
		 */ 
		public function sampleRecv(node:Node, time:uint, ordered:Boolean = false):Vector.<Sequence>
		{
			var id:int = node.id;
			if (!(id in recv)) {
				return null;
			}
			var key:String = String(id) + "-" + String(time) + "-" + (ordered ? "t" : "f");
			if (key in recvCache) {
				return Vector.<Sequence>(recvCache[key]);
			}
			
			var samples:Array = SequencesCollection(recv[id]).sampleItemsAsArray(time, time);
			if (samples.length > 0 && ordered == true) {
				samples.sortOn("seqNum", Array.NUMERIC);
			}
			
			var items:Vector.<Sequence> = Vector.<Sequence>(samples);
			recvCache[key] = items;
			
			return items;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Sample seq num
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample dest  
		 * 
		 * @param time
		 */
		public function sampleDestLastSeqNum(time:uint):int
		{
			if (!destNode) {
				return -1;
			}
			
			return sampleLastSeqNum(destNode, time);
		}
		
		/**
		 * Sample last seq num
		 * 
		 * @param node 
		 * @param time
		 */ 
		public function sampleLastSeqNum(node:Node, time:uint):int
		{
			var id:int = node.id;
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
		

	}
}