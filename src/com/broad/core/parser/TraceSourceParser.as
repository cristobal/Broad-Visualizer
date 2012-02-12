package com.broad.core.parser
{
	import com.broad.core.events.TimedEvent;
	import com.broad.io.FileReader;
	import com.broad.io.Reader;
	import com.broad.io.ReaderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.System;
	
	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="elapsed", type="com.broad.core.events.TimedEvent")]
	
	/**
	 * TraceSourceParser.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class TraceSourceParser extends EventDispatcher
	{
		public function TraceSourceParser(reader:Reader)
		{
			setup(reader);
		}
		
		/**
		 * @private
		 */ 
		private var reader:Reader;
		
		/**
		 * @private
		 */ 
		private var sources:Vector.<TraceSource> = new Vector.<TraceSource>();
		
		/**
		 * Setup
		 */ 
		private function setup(reader:Reader):void
		{
			
			reader.addEventListener(ReaderEvent.READ_LINE, handleLineAdded);
			reader.addEventListener(Event.COMPLETE, handleComplete);
		}
		
		/**
		 * Add trace source 
		 * 
		 * @param item The trace source to…
		 */ 
		public function addTraceSource(item:TraceSource):void
		{
			sources.push(item);
		}
		
		/**
		 * Remove trace source
		 * 
		 * @param item The trace source to remove
		 */ 
		public function removeTraceSource(item:TraceSource):void
		{
			var source:TraceSource;
			for (var i:int = sources.length; i--;) {
				source = sources[i];
				if (source === item) {
					sources.splice(i, 1);
					break;
				}
			}
		}
		
		/**
		 * Handle line add
		 * 
		 * @param event
		 */ 
		private function handleLineAdded(event:ReaderEvent):void
		{
			var source:TraceSource;
			var params:Vector.<String> = Vector.<String>(event.line.split(" "));
			var traceSource:String = params.shift();
			var time:uint, maxTime:uint = 0;
			for (var i:int = 0, l:int = sources.length; i < l; i++) {
				source = sources[i];
				if (source.traceSource == traceSource && params) {
					time = source.update(params);
					if (time > maxTime) {
						dispatchEvent(new TimedEvent(TimedEvent.ELAPSED, false, false, time));
						maxTime = time;
					}
				}
			}
			
			params = null;
		}
		
		/**
		 * Handle complete
		 * 
		 * @param event
		 */ 
		private function handleComplete(event:Event):void
		{
			var source:TraceSource;
			for (var i:uint = 0, l:uint = sources.length; i < l; i++) {
				source = sources[i];
				source.onComplete();
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
			System.gc(); // Garbage collect
		}
	}
}