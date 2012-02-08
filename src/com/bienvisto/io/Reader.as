package com.bienvisto.io
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	// TODO: Handle case where we are writing to stream as well as reading from the stream and yet not finished
	
	/**
	 * Reader.as
	 * 	Base reader class for file and stream reader.
	 *  Process string chunks and notifies when a new line is available 
	 *  and when it has completed reading a file or a stream.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class Reader extends EventDispatcher
	{
		//--------------------------------------
		//
		// Class variables
		//
		//--------------------------------------
		
		/**
 		 * @private
 	     */
		private static var timerDelay:uint	  = 10;
		
		/**
 		 * @private
		 */ 
		private static var maxIterations:uint = 2500;
		
		/**
		 * @private
		 */ 
		private static var EOF:int = int.MIN_VALUE;
		
		/**
		 * @private
		 */
		private static const LF:int = "\n".charCodeAt(0); // Should be dec: 10
	
		/**
		 * @private
		 */
		private static const CR:int = "\r".charCodeAt(0); // Should be dec: 13 
		
		
		//--------------------------------------
		//
		// Constructor
		//
		//--------------------------------------
		public function Reader()
		{
			super();
			setup();
		}
		
		
		//--------------------------------------
		//
		// Variables
		//
		//--------------------------------------
		
		/**
		 * @private
		 */ 
		private var timer:Timer;
		
		/**
		 * @private
		 */ 
		private var complete:Boolean = false;
		
		/**
		 * @private
		 */ 
		private var bytes:ByteArray;

		
		//--------------------------------------
		//
		// Properties
		//
		//--------------------------------------
		
		/**
		 * @readonly is processing
		 */ 
		public function get isProcessing():Boolean
		{
			return timer.running;
		}
		
		//--------------------------------------
		//
		// Methods
		//
		//--------------------------------------
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			bytes = new ByteArray();
			
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
		}
		
		
		/**
		 * Emit line
		 * 
		 * @param line 
		 */ 
		private function emitLine(line:String):void
		{
			if (this.hasEventListener(ReaderEvent.READ_LINE)) {
				this.dispatchEvent(
					new ReaderEvent(ReaderEvent.READ_LINE, false, false, line)
				);
			}
		}
		
		
		//--------------------------------------
		//
		// Chunking
		//
		//--------------------------------------
		
		/**
		 * Start chunking
		 */ 
		protected function start():void
		{
			
			timer.start();
		}
		
		/**
		 * Stop chunking
		 */ 
		protected function stop():void
		{
			complete = true;
		}
		
		/**
		 * Reset
		 */ 
		protected function reset():void
		{
			if (timer.running) {
				timer.stop();
			}
			complete = true;
			bytes.clear();
		}
		
		/**
		 * Add bytes
		 * 
		 * @param data
		 */ 
		protected function addBytes(data:ByteArray):void
		{
			var offset:uint  = bytes.position;
			bytes.writeBytes(data);
			bytes.position = offset; 
		}
		
		/**
		 * Process chunck
		 */ 
		private function processBytes():void
		{
			
			var line:String;
			var iteration:int = 0;
			while (1) {
				line = readLine();
				iteration++;
				
				if (line == "") {
					continue;
				}
				else if (!line) {
					break;
				}
				// Add code under to handle when writing and reading simultaneously…
				/*else if ((bytes.position >= bytes.length) && !complete) {
					
				}
				*/
				
				emitLine(line);
				if (iteration == maxIterations) {
					
					break;
				}
			}
			
			if (!line && complete) {
				timer.stop();
				bytes.clear(); 
				
				if (this.hasEventListener(Event.COMPLETE)) {
					this.dispatchEvent(
						new Event(Event.COMPLETE)
					);
				}
			}
		}
		
		/**
		 * Read line
		 * 
		 * @return 
		 */ 
		private function readLine():String
		{
			var characters:Array = [];
			var char:int;
			var line:String = null;
			
			while ((char = read()) != EOF) {
				if ((char == LF) || (char == CR)) {
					break;
				}
				characters.push(char);
			}
			
			if (characters.length > 0){
				line = String.fromCharCode.apply(String.fromCharCode, characters);
			}
			else if(!line && (char != EOF)){
				line = "";
			}
			
			return line;
		}
		
		/**
		 * Read
		 * 
		 * @return 
		 */ 
		private function read():int 
		{
			var char:int = EOF;
			if (bytes.position < bytes.length) {
				char = bytes[bytes.position++];
			}
			
			return char;
		}
		
		/**
		 * Handle timer
		 * 
		 * @param event
		 */ 
		private function handleTimer(event:TimerEvent):void
		{
			processBytes();
		}

	}
}