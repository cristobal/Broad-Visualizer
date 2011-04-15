package com.bienvisto.elements
{
	import com.bienvisto.elements.sequences.Sequence;
	
	import mx.core.FlexGlobals;

	public class SequencesManager
	{
		public function SequencesManager()
		{
		}
		
		/**
		 * @private
		 */ 
		private var sent:Vector.<Sequence>;
		
		/**
		 * @private
		 */ 
		private var recv:Vector.<Sequence>;
		
		/**
		 * Update
		 * 
		 * @param time
		 * @param type
		 * @param sequences
		 */ 
		public function update(time:uint, type:String, sequences:Vector.<Sequence>):void
		{
			if (type == "ss") {
				sent = sequences;
			}
			else {
				recv = sequences;
			}
			
			var method:String = "update";
			FlexGlobals.topLevelApplication["sequencesWindow"][method](sent, recv);
		}
	}
}