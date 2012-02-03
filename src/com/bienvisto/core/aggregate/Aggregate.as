package com.bienvisto.core.aggregate
{
	import com.bienvisto.util.OIDUtil;

	/**
	 * Aggregate.as
	 * 	The basic class for an aggregate.
	 *  Has a timestamp and a value.
	 * 
	 * @author Cristobal Dabed 
	 */ 
	public class Aggregate
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructur
		 * 
		 * @param time
		 */ 
		public function Aggregate(time:uint)
		{
			_time = time;
			_oid  = "ca-" + String(time) + "-" + OIDUtil.getNext();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//

		
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
		
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  time
		//---------------------------------- 
		/**
		 * @private
		 */
		private var _time:uint;
		
		/**
		 * @readonly time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
	}
}