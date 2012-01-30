package com.bienvisto.core.aggregate
{
	import mx.utils.UIDUtil;

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
			_uuid = UIDUtil.createUID();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//

		
		//----------------------------------
		// uuid 
		//---------------------------------- 
		/**
		 * @private
		 */
		private var _uuid:String;
		
		/**
		 * @readonly time
		 */ 
		public function get uuid():String
		{
			return _uuid;
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