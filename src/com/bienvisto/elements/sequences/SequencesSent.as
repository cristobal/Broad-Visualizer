package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="change", type="flash.events.Event")]
	
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
			}
			
			var sequence:Sequence = new Sequence(time, seqNum);
			SequencesCollection(collections[id]).add(sequence);
			if (!(seqNum in map)) {
				map[seqNum] = sequence;
			}
			_lastSeqNum = seqNum;
			
			if (first) {
				_sourceNode = parent.nodeContainer.getNode(id);
				
				dispatchEvent(new Event(Event.CHANGE));
				first = false;

			}
			
			return time;
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
		
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleSourceTotal(time:uint):int
		{
			return sampleTotal(sourceNode, time);
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
		
		/**
		 * Sample source rate
		 * 
		 * @param time
		 */ 
		public function sampleSourceRate(time:uint):int
		{
			return sampleRate(sourceNode, time);
		}
		
		/**
		 * Sample dest  
		 */
		public function sampleSourcelastSeqNum(time:uint):int
		{
			var id:int = sourceNode ? sourceNode.id : -1;
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