package com.bienvisto.elements.drops
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	public class Drops extends TraceSource implements ISimulationObject
	{
		public function Drops(nodeContainer:NodeContainer)
		{
			super("Mac Drops", "md");
			
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var collections:Dictionary = new Dictionary()
			
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			
			if (!(id in collections)) {
				collections[id] = new DropsCollection();
			}
			
			DropsCollection(collections[id]).add(
				new Aggregate(time)
			);
			
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
		
		/**
		 * Sample items
		 * 
		 * @param node
		 * @param time
		 * @param windowSize
		 */ 
		public function sampleItems(node:Node, time:uint, windowSize:int):Vector.<Aggregate>
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return DropsCollection(collections[id]).sampleItems(time, windowSize);
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
			
			return DropsCollection(collections[id]).sampleTotal(time);
		}
		
		/**
		 * Sample total with window size
		 * 
		 * @param node
		 * @param time
		 * @param windowSize
		 */ 
		public function sampleTotalWithWindowSize(node:Node, time:uint, windowSize:int):int
		{
			var items:Vector.<Aggregate> = sampleItems(node, time, windowSize);
			return items ? items.length : 0;
		}
	}
}