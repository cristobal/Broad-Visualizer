package com.gran.elements.drops
{
	import com.gran.core.ISimulationObject;
	import com.gran.core.aggregate.Aggregate;
	import com.gran.core.aggregate.AggregateCollection;
	import com.gran.core.aggregate.IAggregateProvider;
	import com.gran.core.network.node.Node;
	import com.gran.core.network.node.NodeContainer;
	import com.gran.core.parser.TraceSource;
	
	import flash.utils.Dictionary;
	
	/**
	 * Drops.as
	 * 	Class responsible of parsing "mac drops" from the trace source.
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public class Drops extends TraceSource implements ISimulationObject, IAggregateProvider
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * 
		 * @param nodeContainer
		 */
		public function Drops(nodeContainer:NodeContainer)
		{
			super("Mac Drops", "md");
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 * 	A reference to the node container
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 * 	A collection of AggregateCollection that store the aggregates for given time for each node
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A hash map to lookup sampled items that have already been calculated
		 */ 
		private var samples:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	The last point in time at which we sampled a mac drop
		 */ 
		private var delta:uint = uint.MAX_VALUE;
		
		/**
		 * @private
		 */ 
		private var complete:Boolean = false;
		
		
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
			samples		= new Dictionary();
			delta		= uint.MAX_VALUE;
			complete	= false;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Override TraceSource Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override
		 */ 
		override public function onComplete():void
		{
			complete = true;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
				samples[id]		= new Dictionary();
			}
			
			AggregateCollection(collections[id]).add(
				new Aggregate(time)
			);
			delta = time;
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		
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
			
			var key:String = String(time) + "-" + String(windowSize);
			if (key in samples[id]) {
				return Vector.<Aggregate>(samples[id][key]);	
			}
			
			var items:Vector.<Aggregate>  = AggregateCollection(collections[id]).sampleItems(time, windowSize);
			
			// only cache after parsing completed or if the time is before the last sampled value
			if (complete || time < delta) {
				samples[key] = items;
			}
			
			return items;
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
			
			return AggregateCollection(collections[id]).sampleTotal(time);
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
		
		/**
		 * Sample rate
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleRate(node:Node, time:int):int
		{
			
			var id:int = node.id;
			if (!(id in collections)) {
				return 0;	
			}
			
			var rate:int = 0;
			var collection:AggregateCollection = AggregateCollection(collections[id]);
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
		
		
		//--------------------------------------------------------------------------
		//
		//  IAggregateDataProvider Implementation
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Get items
		 * 
		 * @param node
		 */ 
		public function getItems(node:Node):Vector.<Aggregate>
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return AggregateCollection(collections[id]).items;
		}
		
	}
}