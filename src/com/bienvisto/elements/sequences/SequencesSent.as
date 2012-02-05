package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * SequencesSent.as
	 * 	Class responsible of parsing "sequences sent" block of the trace.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesSent extends TraceSource implements ISimulationObject
	{
		public function SequencesSent(parent:SequencesContainer)
		{
			super("SequencesSent", "ss");
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
		private var unique:Dictionary = new Dictionary();
		
		/**
		 * @priavte
		 */ 
		private var map:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var rateCache:Dictionary = new Dictionary();

		/**
		 * @private
		 */	
		private var first:Boolean = true;
		
		/**
		 * @private
		 */ 
		private var _sourceNode:Node;
		
		/**
		 * @readonly sourceNode
		 */ 
		public function get sourceNode():Node
		{
			return _sourceNode;
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
				unique[id]		= new AggregateCollection();
			}
			
			var sequence:Sequence = new Sequence(time, seqNum);
			SequencesCollection(collections[id]).add(sequence);
			
			// add unique
			if (!(seqNum in map)) {
				AggregateCollection(unique[id]).add(sequence);
				map[seqNum] = sequence;
			}
			
			if (first) {
				_sourceNode = parent.nodeContainer.getNode(id);
				
				dispatchEvent(new Event(Event.INIT));
				first = false;
			}
			
			return time;
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
			
			return SequencesCollection(collections[id]).sampleTotal(time);
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