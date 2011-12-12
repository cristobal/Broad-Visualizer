package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	
	/**
	 * TransmissionsParser.as
	 * 	A parser subclass which parses all the trace sources 
	 *  for the mac transmisions event type in the simulations.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Transmissions extends TraceSource implements ISimulationObject
	{
		public function Transmissions(nodes:NodeContainer)
		{
			super("Mac Transmissions", "mt"); // mac transmissions
			
			this.nodes = nodes;
		}
		
		/**
		 * @private
		 */ 
		private var nodes:NodeContainer;
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):void
		{
						
			// format: mt <node id> <time> <packet_size> <next_hop_id> 
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var size:Number = uint(params[2]);
			var destination:int = params.length > 3 ? uint(params[3]) : -1;
			
			var transmission:Transmission = new Transmission(time, id, destination, size);
			nodes.getNode(id).addTransmission(transmission);
		}
		
		/**
		 * On time update
		 * 
		 * @parm elapsed
		 */ 
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
	}
}