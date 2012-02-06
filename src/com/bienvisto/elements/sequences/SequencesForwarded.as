package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * SequencesForwarded.as
	 * 	 Class responsible of parsing "sequences forwarded" from the trace source.
	 * 
	 * @author Cristobal Dabed
	 */
	public class SequencesForwarded extends TraceSource implements ISimulationObject
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
		public function SequencesForwarded(parent:SequencesContainer)
		{
			super("Sequences Forwarded", "sf");
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
		 * 	A collection of AggregateCollection that store sequences that have been forwaded from a node
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		
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
			// Format: sf <id> <time> <seqNum> <dest>
			var id:int    = int(params[0]);
			var time:uint = uint(params[1]);
			var seqNum:int = uint(params[2]);
			var dest:int  = int(params[3]);
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
			}
			
			var sequence:Sequence = new Sequence(time, seqNum);
			AggregateCollection(collections[id]).add(sequence);
			
			// Tell the sequences inserted trace source that the sequence has been removed.
			// Since it has been forwarded from the current node
			parent.inserted.removeSequence(
				parent.nodeContainer.getNode(id), sequence
			);
			
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
		
	}
}