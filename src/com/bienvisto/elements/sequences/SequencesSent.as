package com.bienvisto.elements.sequences
{
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.elements.ElementBase;
	
	import flash.display.Sprite;
	
	/**
	 * Class responsible of parsing "sequences sent" block of the trace.
	 */ 
	public class SequencesSent extends ElementBase
	{
		public function SequencesSent(v:Visualizer, c:Sprite=null)
		{
			super(v, c);
		}
		
		/**
		 * @private
		 */ 
		private var sequences:Sequences = new Sequences();
		
		/**
		 * @override
		 */ 
		public override function get name():String 
		{
			return "SequencesSent";
		}
		
		/**
		 * @override
		 */ 
		public override function get lineType():String
		{
			return "ss"; // sequence sent
		}
		
		/**
		 * Function called when a STEP event is raised. Updates the status of
		 * the sequences data and modifies the appearance of the sequences sent 
		 * according to what has been sent
		 */
		public override function update(event:TimedEvent):void
		{
			var time:uint = event.elapsed;
			visualizer_.sequencesManager.update(time, lineType, sequences.getDataForTime(time));
		}
		
		/**
		 * @override
		 */ 
		protected override function loadNewLine(params:Array):void
		{
			var id:int = params[0];
			var time:uint = params[1];
			var seqNum:uint = params[2];
			
			sequences.addData(id, time, seqNum);
		}
	}
}