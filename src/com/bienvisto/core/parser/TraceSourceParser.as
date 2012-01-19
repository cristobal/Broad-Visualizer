package com.bienvisto.core.parser
{
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.io.FileReader;
	import com.bienvisto.io.Reader;
	import com.bienvisto.io.ReaderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="elapsed", type="com.bienvisto.core.events.TimedEvent")]
	
	/**
	 * TraceFileParser.as
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
				if (source.traceSource == traceSource) {
					time = source.update(params);
					if (time > maxTime) {
						dispatchEvent(new TimedEvent(TimedEvent.ELAPSED, false, false, time));
						maxTime = time;
					}
				}
			}
			
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
		}
	}
}