package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * SequencesForwarded.as
	 * 
	 * @author Cristobal Dabed
	 */
	public class SequencesForwarded extends TraceSource implements ISimulationObject
	{
		public function SequencesForwarded(parent:SequencesContainer)
		{
			super("Sequences Forwarded", "sf");
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
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// Format: sf <id> <time> <seqNum> <dest>
			var id:int    = int(params[0]);
			var time:uint = uint(params[1]);
			var seqNum:int = uint(params[2]);
			var dest:int  = int(params[3]);
			
			if (!(id in collections)) {
				collections[id] = new SequencesCollection();
			}
			
			var sequence:Sequence = new Sequence(time, seqNum);
			SequencesCollection(collections[id]).add(sequence);
			
			if (!seqNum in map) {
				map[seqNum] = sequence;
			}
			parent.inserted.removeSequence(
				parent.nodeContainer.getNode(id), sequence
			);
			
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
		
		public function onTimeUpdate(elapsed:uint):void
		{
		}
		
		public function setDuration(duration:uint):void
		{
		}
	}
}