package com.bienvisto.elements.routing
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.events.Event;
	
	/**
	 * RoutingProtocol.as
	 * 
	 * @author Cristobal Dabed
	 */
	public final class RoutingProtocol extends TraceSource implements ISimulationObject
	{
		public function RoutingProtocol()
		{
			super("Routing Protocol", "rp");
		}
		
		/**
		 * @private
		 */ 
		private var _routingProtocol:String = "-";
		
		/**
		 * @readonly
		 */ 
		public function get routingProtocol():String
		{
			return _routingProtocol;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// FORMAT: rp OLSR/AODV
			_routingProtocol = params[0];
			
			dispatchEvent(new Event(Event.CHANGE));
			
			return 0;
		}
		
		public function onTimeUpdate(elapsed:uint):void
		{
		}
		
		public function setDuration(duration:uint):void
		{
		}
	}
}