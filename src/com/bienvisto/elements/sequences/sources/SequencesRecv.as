package com.bienvisto.elements.sequences.sources
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.core.network.node.NodeContainer;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.sequences.Sequence;
	import com.bienvisto.elements.sequences.SequencesContainer;
	import com.bienvisto.elements.sequences.SequencesStats;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * @Event
	 * 	The init event will be dispatched when the first sequence recv has been parsed.
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * SequecesRecv.as
	 *  Class responsible of parsing "sequences recv" from the trace source.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesRecv extends TraceSource implements ISimulationObject, IAggregateProvider
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
		public function SequencesRecv(parent:SequencesContainer)
		{
			super("SequencesRecv", "sr");
			this.parent		   = parent;
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
		 * 	A collection of SequencesCollection for each node
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A hash map to lookup sequences that have been recv by seqNum
		 */ 
		private var map:Dictionary = new Dictionary();
		
		/**
		 * @private
		 *  A collection of AggregateCollection that stores sequences stats aggregate items for each node
		 */ 
		private var stats:Dictionary = new Dictionary();

		/**
		 * @private
		 *  A collection of SequencesCollection that stores each unique sequences recv at destination node
		 */ 
		private var recv:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A hash map to lookup already sampled sequence items
		 */ 
		private var recvCache:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A collection of AggregateColletion that stores sequences that have been dropped at destination node
		 */ 
		private var drops:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var init:Boolean = false;
		
		/**
		 * @private
		 */ 
		private var complete:Boolean = false;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  destNode
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _destNode:Node;
		
		/**
		 * @readonly destNode
		 * 	The destination node where all video sequence are sent to
		 */ 
		public function get destNode():Node
		{
			return _destNode;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Override TraceSource Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function onComplete():void
		{
			complete = true;
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
				collections[id] = new AggregateCollection();
				recv[id]		= new AggregateCollection();
				stats[id]	    = new AggregateCollection();
				drops[id]		= new AggregateCollection();
				map[id]			= new Dictionary();
			}
			
			
			var sequence:Sequence = new Sequence(time, seqNum);
			AggregateCollection(collections[id]).add(sequence);
			
			var node:Node = parent.nodeContainer.getNode(id);
			updateDrops(node, sequence);
			updateStats(node, sequence);
			
			if (!init) {
				_destNode = node;
				
				dispatchEvent(new Event(Event.INIT));
				init = true;
			}
			
			return time;
		}
		
		/**
		 * Update drops
		 * 
		 * @param node
		 * @param sequence
		 */ 
		private function updateDrops(node:Node, sequence:Sequence):void
		{
			var id:int = node.id;
			if (sequence.seqNum in map[id]) {
				AggregateCollection(drops[id]).add(sequence);
			}
		}
		
		/**
		 * Update state
		 * 
		 * @param node
		 * @param sequence
		 */ 
		private function updateStats(node:Node, sequence:Sequence):void
		{
			var id:int 	   = node.id;
			var seqNum:int = sequence.seqNum;
			var time:uint  = sequence.time;
			if (!(seqNum in map[id])) {
				map[id][seqNum] = sequence;
				
				var sent:Sequence       = parent.sent.findSequenceBySeqNum(node, seqNum);
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
				
				AggregateCollection(recv[id]).add(sequence);
			}
		}
		
		
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
			recv		= new Dictionary();
			stats       = new Dictionary();
			map		    = new Dictionary();
			recvCache   = new Dictionary(); 
			
			complete = false;
			init     = false;
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
			
			return AggregateCollection(collections[id]).sampleTotal(time);
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
			var collection:AggregateCollection = AggregateCollection(collections[id]);
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
			
			var samples:Array = AggregateCollection(recv[id]).sampleItemsAsArray(time, time);
			if (samples.length > 0 && ordered == true) {
				samples.sortOn("seqNum", Array.NUMERIC);
			}
			
			var items:Vector.<Sequence> = Vector.<Sequence>(samples);
			
			// only store if the parsing is complete
			if (complete) {
				recvCache[key] = items;
			}
			
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
			
			var item:Sequence = Sequence(AggregateCollection(collections[id]).findNearest(time));
			return item ? item.seqNum : -1;
		}

		/**
		 * Find seq num
		 * 
		 * @param seqNum
		 */ 
		public function findSequenceBySeqNum(node:Node, seqNum:int):Sequence
		{
			var id:int = node.id;
			if (!(id in map)) {
				return null;
			}
			
			return Sequence(map[id][seqNum]);
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