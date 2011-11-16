package com.bienvisto.core.aggregate
{
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
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
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