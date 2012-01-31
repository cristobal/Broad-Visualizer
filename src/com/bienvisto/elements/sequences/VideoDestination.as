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
	 * VideoDestination.as
	 * 
	 * @author Cristobal Dabed
	 */
	public final class VideoDestination extends TraceSource implements ISimulationObject
	{
		
		public function VideoDestination(nodeContainer:NodeContainer)
		{
			super("Video Destination", "vd");
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var map:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var _nodes:Vector.<Node>;
		
		/**
		 * @readonly
		 */ 
		public function get nodes():Vector.<Node>
		{
			return _nodes;
		}
		
		/**
		 * @override
		 */
		override public function update(params:Vector.<String>):uint
		{
			var id:int = params[0];
			
			if (!(id in map)) {
				var node:Node = nodeContainer.getNode(id);
				_nodes.push(node);
				
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			
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