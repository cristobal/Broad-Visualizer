package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.aggregate.Aggregate;

	/**
	 * SequencesStats.as
	 * 
	 * @uathor Cristobal Dabed
	 */ 
	public class SequencesStats extends Aggregate
	{
		public function SequencesStats(time:uint, value:Number, total:int)
		{
			super(time);
			
			_avg   = value / total;
			_value = value;
			_total = total;
		}
		
		/**
		 * @private
		 */ 
		private var _avg:Number;
		
		/**
		 * @readonly avg
		 */ 
		public function get avg():Number
		{
			return _avg;
		}
		
		/**
		 * @private
		 */ 
		private var _value:Number;
		
		/**
		 * @readonly value
		 */ 
		public function get value():Number
		{
			return _value;
		}
		
		/**
		 * @private
		 */ 
		private var _total:Number;
		
		/**
		 * @readonly total
		 */ 
		public function get total():Number
		{
			return _total;
		}
		
	}
}