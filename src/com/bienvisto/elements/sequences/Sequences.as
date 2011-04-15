package com.bienvisto.elements.sequences
{
	/**
	 * Sequences.as
	 */ 
	public final class Sequences
	{
		
		/**
		 * Constructor
		 */ 
		public function Sequences()
		{
		}
		
		/**
		 * private
		 */ 
		private var _data:Vector.<Sequence> = new Vector.<Sequence>();
		
		/**
		 * @readonly data
		 */ 
		public function get data():Vector.<Sequence>
		{
			return _data.concat();
		}
		
		/**
		 * Add data
		 * 
		 * @param id
		 * @param time
		 * @param seqNum
		 */ 
		public function addData(id:int, time:uint, seqNum:uint):void
		{
			addSequence(new Sequence(id, time, seqNum));
		}
		
		/**
		 * Add sequence
		 * 	
		 * @param sequence
		 */ 
		public function addSequence(sequence:Sequence):void
		{
			_data.push(sequence);
		}
		
		/**
		 * Get data for time
		 * 
		 * 
		 * @param time
		 */ 
		public function getDataForTime(time:uint):Vector.<Sequence>
		{
			// TODO: Optimize code here…
/*			var total:uint = _data.length;
			var sequence:Sequence;
			for (var i:int = _data.length; i--;) {
				sequence = _data[i];
				if (sequence.time >= time) {
					total--;	
				}
				else {
					break;
				}
			} 
			return _data.slice(_data.length - total);
			*/
			
			var values:Vector.<Sequence> = new Vector.<Sequence>();
			var sequence:Sequence;
			for (var i:uint = 0, l:uint = _data.length; i < l; i++) {
				sequence = _data[i];
				if (sequence.time <= time) {
					values.push(sequence);
				}
				else {
					break;
				}
			}
			
			return values;
		}
		
	}
}