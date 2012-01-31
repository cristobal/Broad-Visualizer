package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	/**
	 * SequencesInserted.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesInserted extends TraceSource implements ISimulationObject
	{
		public function SequencesInserted(nodeContainer:NodeContainer)
		{
			super("Sequences Inserted", "si");
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			var id:int = int(params[0]);
			var time:int = uint(params[1]);
		}
		
		public function onTimeUpdate(elapsed:uint):void
		{
		}
		
		public function setDuration(duration:uint):void
		{
		}
	}
}