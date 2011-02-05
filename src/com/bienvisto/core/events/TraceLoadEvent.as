package com.bienvisto.core.events
{
	import flash.events.Event;
 
	/**
	 * Events raised while loading the trace file. This events are used by the
	 * visualizer components to load their part of the trace file.
	 *
	 * @author Miguel Santirso
	 */
	public class TraceLoadEvent extends Event
	{

		/**
		 * The block of the trace file associated to the event
		 */
		protected var traceBlock_:Object;
		/**
		 * The type of the trace block (topology, communications, ...)
		 */
		protected var blockType_:String;


		/**
		 * Constructor of the event. Needs to be passed the block of the trace
		 * file associated to the event and its block type
		 *
		 * @param traceBlock The block of the trace file associated to this 
		 * event
		 */
		public function TraceLoadEvent (type:String, blockType:String, traceBlock:Object, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			traceBlock_ = traceBlock;
			blockType_ = blockType;
		}


		public override function clone():Event
		{
			return new TraceLoadEvent(type, blockType_, traceBlock_, bubbles, cancelable);
		}


		public function get traceBlock():Object { return traceBlock_; }
		public function get blockType():String { return blockType_; }


	}
}
