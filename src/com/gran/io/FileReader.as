package com.gran.io
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;

	/**
	 * FileReader.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class FileReader extends Reader
	{
		/**
		 * Constructor
		 */ 
		public function FileReader()
		{
			super();
		}
		
		/**
		 * @private
		 */ 
		private var loader:URLStream = new URLStream();
		
		/**
		 * Load the give file
		 * 
		 * @param filenam
		 */ 
		public function load(filename:String):void
		{
			loader.addEventListener(ProgressEvent.PROGRESS, handleProgress, false, 0, true);
			loader.addEventListener(Event.COMPLETE, handleComplete, false, 0 , true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError, false, 0 , true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError, false, 0 , true);  

			
			loader.load(new URLRequest(filename));
			start();
		}
		
		//--------------------------------------
		//
		// Events
		//
		//--------------------------------------
		
		/**
		 * Called each time some data has been loaded
		 * 
		 * @param event The flash event
		 */ 
		private function handleProgress(event:ProgressEvent):void {
			/*addChunk(
				loader.readUTFBytes(loader.bytesAvailable)
			);*/
		}
		
		/**
		 * On complete
		 * 
		 * @param event The flash event
		 */ 
		private function handleComplete(event:Event):void {
			//
			stop();
		}
		
		/**
		 * On io error
		 * 
		 * @param error The IO error
		 */ 
		private function handleIOError(ioError:IOError):void {

		}
		
		/**
		 * On security error
		 * 
		 * @param error The security error
		 */ 
		private function handleSecurityError(securityError:SecurityErrorEvent):void {

		} 
	}
}