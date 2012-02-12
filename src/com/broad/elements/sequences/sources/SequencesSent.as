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
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * @Event
	 * 	The init event will be dispatched when the first sent sequence has been parsed.
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * SequencesSent.as
	 * 	Class responsible of parsing "sequences sent" from the trace source.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesSent extends TraceSource implements ISimulationObject, IAggregateProvider
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
		public function SequencesSent(parent:SequencesContainer)
		{
			super("SequencesSent", "ss");
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
		 * 	A collection of SequencesCollection for each node
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A collection of AggregateColletion that stores each unique sequences sent from source node
		 */ 
		private var unique:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A hash map to lookup sequences that have been sent by seqNum
		 */ 
		private var map:Dictionary = new Dictionary();
		
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
		//  sourceNode
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _sourceNode:Node;
		
		/**
		 * @readonly sourceNode
		 * 	The source node where all video sequence are sent from
		 */ 
		public function get sourceNode():Node
		{
			return _sourceNode;
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
			unique      = new Dictionary();
			map		    = new Dictionary();
			
			complete = false;
			init     = false;
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
				unique[id]		= new AggregateCollection();
				map[id]			= new Dictionary();
			}
			
			var sequence:Sequence = new Sequence(time, seqNum);
			AggregateCollection(collections[id]).add(sequence);
			
			// add unique
			if (!(seqNum in map[id])) {
				AggregateCollection(unique[id]).add(sequence);
				map[id][seqNum] = sequence;
			}
			
			if (!init) {
				_sourceNode = parent.nodeContainer.getNode(id);
				dispatchEvent(new Event(Event.INIT));
				init = true;
			}
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Sample total
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleSourceTotal(time:uint):int
		{
			if (!sourceNode) {
				return 0;
			}
			
			return sampleTotal(sourceNode, time);
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
			
			return AggregateCollection(collections[id]).sampleTotal(time);
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Sample unique
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample source unique
		 * 
		 * @param time
		 */ 
		public function sampleSourceUnique(time:uint):int
		{
			if (!sourceNode) {
				return 0;
			}
			
			return sampleUnique(sourceNode, time);
		}
		
		/**
		 * Sample unique
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleUnique(node:Node, time:uint):int
		{
			var id:int = node.id;
			if (!(id in unique)) {
				return 0;
			}
			
			return AggregateCollection(unique[id]).sampleTotal(time);
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Sample source rate
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample source rate
		 * 
		 * @param time
		 */ 
		public function sampleSourceRate(time:uint):int
		{
			if (!sourceNode) {
				return 0;
			}
			
			return sampleRate(sourceNode, time);
		}		
		
		/**
		 * Samplerate
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleRate(node:Node, time:uint):int
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
		// Sample seq num
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Sample source last seq num
		 *   
		 * @param time
		 */
		public function sampleSourceLastSeqNum(time:uint):int
		{
			if (!sourceNode) {
				return -1;
			}
			
			return sampleLastSeqNum(sourceNode, time);
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