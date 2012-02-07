package com.bienvisto.core.aggregate
{
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.util.OIDUtil;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	/**
	 * AggregateDataProvider.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class AggregateDataProvider
	{
		public function AggregateDataProvider(name:String, color:uint = 0xFF0000, minimumResolution:Number = 1000.0, maximumResolution:Number = 10000.0)
		{
			_name = name;
			
			_color			   = color;
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
		
		/**
		 * @private
		 */ 
		private var _color:uint;
		
		/**
		 * @readonly color
		 */ 
		public function get color():uint
		{
			return _color;
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
		 * Get list
		 * 
		 * @param resolution
		 * @param nodes
		 */ 
		public function getList(resolution:Number, nodes:Vector.<Node>):ArrayCollection
		{
			throw new Error("Subclass must implement this method");
			return null;
		}
	}
}