package com.bienvisto.core.parser
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
		//  eventType
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
		
		/**
		 * Called when there are new sources for this eventType
		 * 
		 * @param args The params parsed from the trace source
		 */ 
		public function update(params:Vector.<String>):void
		{
			throw new Error("Subclass must override this method");
		}
	}
}