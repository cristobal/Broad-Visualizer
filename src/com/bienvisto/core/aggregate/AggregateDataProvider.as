package com.bienvisto.core.aggregate
{
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.util.OIDUtil;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	/**
	 * AggregateDataProvider.as
	 * 	Old VariableBase class
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public class AggregateDataProvider
	{
		public function AggregateDataProvider(name:String, provider:IAggregateProvider, minimumResolution:Number = 1000.0, maximumResolution:Number = 10000.0) {
		
			_name = name;
			_provider = provider;
			
			_minimumResolution = minimumResolution;
			_maximumResolution = maximumResolution;
			
			_oid  = "adp-" + OIDUtil.getNext();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		// oid 
		//---------------------------------- 
		/**
		 * @private
		 */
		private var _oid:String;
		
		/**
		 * @readonly time
		 */ 
		public function get oid():String
		{
			return _oid;
		}
		
		//----------------------------------
		// name
		//---------------------------------- 
		/**
		 * @private
		 */ 
		private var _name:String;
		
		/**
		 * @readonly name
		 */ 
		public function get name():String
		{
			return _name;
		}
		
		//----------------------------------
		// provider
		//---------------------------------- 
		/**
		 * @private
		 */ 
		private var _provider:IAggregateProvider;
		
		/**
		 * @readonly provider
		 */ 
		public function get provider():IAggregateProvider
		{
			return _provider;
		}
		
		/**
		 * @private
		 */ 
		private var _minimumResolution:Number;
		
		/**
		 * @readonly minimumResolution
		 */ 
		public function get minimumResolution():Number
		{
			return _minimumResolution;
		}
		
		/**
		 * @private
		 */ 
		private var _maximumResolution:Number;
		
		/**
		 * @readonly minimumResolution
		 */ 
		public function get maximumResolution():Number
		{
			return _maximumResolution;
		}
		
		/**
		 * Get values
		 * 
		 * @param resolution
		 * @param nodes
		 */ 
		public function getValues(resolution:Number, nodes:Vector.<Node>):ArrayCollection
		{
			// var start:int = getTimer();
			
			var values:Array = new Array();
			var node:Node, id:int;
			
			var items:Vector.<Aggregate>, item:Aggregate;
			var map:Dictionary = new Dictionary();

			var group:int, data:AggregateData;
			var key:int;
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node  = nodes[i];
				items = provider.getItems(node);
				if (items) {
					for (var x:int = 0, n:int = items.length; x < n; x++) {
						item  = items[x];
						group = Math.floor(item.time / resolution);
						
						// If such group does not exist, we create a new one
						if (values[group] == null)
						{
							data = new AggregateData();
							data.hAxis  = group * resolution;
							data.nodeId = node.id;
							values[group] = data;
						}
						values[group].vAxis = aggregateSum(values[group].vAxis, group, key, item);
					}
				}
			}
			
			// trace("Processed values for:", name, " in total of:", getTimer() - start, "ms; total of:", values.length, " values sampled");
			return new ArrayCollection(values);
		}
		
		/**
		 * Aggregate sum
		 * 
		 * @param value
		 * @param oldValue
		 * @param group
		 * @parak size (key)
		 * @param item
		 */ 
		protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			throw new Error("Subclass must implement this method");
			return 0;
		}
		
	}
}