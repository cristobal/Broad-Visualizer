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
		public function SequencesForwarded(nodeContainer:NodeContainer)
		{
			super("Sequences Forwarded", "sf");
			
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			var id:int    = int(params[0]);
			var time:uint = uint(params[1]);
			var dest:int  = int(params[2]);
			var seqNum:int = -1;
			
			if (!(id in collections)) {
				collections[id] = new SequencesCollection();
			}
			
			SequencesCollection(collections[id]).add(
				new Sequence(time, seqNum)
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