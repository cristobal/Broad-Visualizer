package com.bienvisto.elements.drops
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	
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
			
			var item:Aggregate = new Aggregate(time);
			var collection:DropsCollection;
			if (!(id in collections)) {
				collection = new DropsCollection();
				collections[id] = collection;
			}
			else {
				collection = DropsCollection(collections[id]);
			}
			
			collection.add(item);
			
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
		public function sampleItems(node:Node, time:uint, windowSize:uint):Vector.<Aggregate>
		{
			var samples:Vector.<Aggregate>;
			var id:int = node.id;
			var collection:DropsCollection;
			if (id in collections) {
				collection = DropsCollection(collections[id]);
				samples	   = collection.sampleItems(time, windowSize);
			}
			
			return samples;
		}
		
		
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleTotal(node:Node, time:uint):int
		{
			var total:int = 0;
			var id:int = node.id;
			
			if (id in collections) {
				var collection:DropsCollection = DropsCollection(collections[id]);
				total = collection.sampleTotal(time);
			}
			
			return total;
		}
		
	}
}