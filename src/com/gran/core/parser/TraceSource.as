package com.gran.core.parser
{
	import flash.events.EventDispatcher;

	/**
	 * Parser.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class TraceSource extends EventDispatcher
	{
		/**
		 * Constructor
		 * 
		 * @param eventType
		 * @param traceSource
		 */ 
		public function TraceSource(eventType:String, traceSource:String)
		{
			super();
			_eventType = eventType;
			_traceSource = traceSource;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  eventType
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _eventType:String;
		
		/**
		 * @readonly eventType
		 */ 
		public function get eventType():String
		{
			return _eventType;
		}		
		
		//----------------------------------
		//  traceSource
		//---------------------------------- 
		/**
		 * @private
		 */ 
		private var _traceSource:String;
		
		/**
		 * @readonly traceSource
		 */ 
		public function get traceSource():String
		{
			return _traceSource;	
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On complete
		 * 	Will be called when the trace source has completed parsing
		 */ 
		public function onComplete():void
		{
			
		}
		
		/**
		 * Called when there are new sources for this eventType
		 * 
		 * @param args The params parsed from the trace source
		 * @return Should return latest parsed time or 0
		 */ 
		public function update(params:Vector.<String>):uint
		{
			throw new Error("Subclass must override this method");
		}
		
	}
}