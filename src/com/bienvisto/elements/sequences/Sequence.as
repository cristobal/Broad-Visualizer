package com.bienvisto.elements.sequences
{
	/**
	 * Sequence.as
	 * 
	 * 	Non-mutable representation of a sequence. 
	 */ 
	public final class Sequence
	{
		/**
		 * Constructor
		 */ 
		public function Sequence(id:int, time:uint, seqNum:int)
		{
			_id = id;
			_time = time;
			_seqNum = seqNum;
		}
		
		/**
		 * @private
		 */ 
		private var _id:int;
		
		/**
		 * @readonly id
		 */ 
		public function get id():int 
		{
			return _id;
		}
		
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