package com.broad.elements.sequences
{
	import com.broad.core.aggregate.Aggregate;

	/**
	 * Sequence.as
	 * 
	 * 	Non-mutable representation of a sequence. 
	 */ 
	public final class Sequence extends Aggregate
	{
		/**
		 * Constructor
		 */ 
		public function Sequence(time:uint, seqNum:uint)
		{
			super(time);
			
			_seqNum = seqNum;
		}
		
		/**
		 * @private
		 */ 
		private var _seqNum:uint;
		
		/**
		 * @readonly seqNum
		 */ 
		public function get seqNum():uint
		{
			return _seqNum;
		}
		
	}
}