package com.bienvisto.elements.drops
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * Drops.as
	 * 	Class responsible of parsing "mac drops" from the trace source.
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public class Drops extends TraceSource implements ISimulationObject
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
			
			// only cache if parsing complete
			if (complete) {
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
		
	}
}