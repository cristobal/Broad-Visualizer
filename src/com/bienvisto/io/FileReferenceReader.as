package com.bienvisto.io
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	/**
	 * @Event
	 * 	Will dispatch an ioError event if the user tries to upload an new file while 
	 *  a file is already being processed.
	 */ 
	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	/**
	 * FileReferenceReader.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class FileReferenceReader extends Reader
	{
		public function FileReferenceReader()
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
		 * 	A filereference used to interact with user and load up the contents for the trace file
		 */ 
		private var fileReference:FileReference;
		
		/**
		 * @private
		 */ 
		private var offset:uint = 0; 
		
		
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
			fileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, handleSelect);
			
			fileReference.addEventListener(ProgressEvent.PROGRESS, handleProgress);
			fileReference.addEventListener(Event.COMPLETE, handleComplete);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
		}
		
		/**
		 * Browse
		 */ 
		public function browse(typeFilter:Array=null):void
		{
			fileReference.browse(typeFilter);
		}

		
		//--------------------------------------
		//
		// FileReference Events
		//
		//--------------------------------------
		
		/**
		 * Handle select
		 * 
		 * @param event
		 */ 
		private function handleSelect(event:Event):void
		{
			if (isProcessing) {
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
				return;
			}
			
			fileReference.load(); // automaticall start uploading the file
			start();
		}
		
		/**
		 * Handle progress
		 * 
		 * @param event
		 */ 
		private function handleProgress(event:ProgressEvent):void
		{
			// Not possible to chunk at this stage…
			/*var bytes:ByteArray = new ByteArray();
			fileReference.data.readBytes(bytes, offset);
			offset += bytes.length;
			addChunk(
				bytes.toString()
			);
			*/
			
		}
		
		/**
		 * Handle complete
		 * 
		 * @param event
		 */ 
		private function handleComplete(event:Event):void
		{
			addBytes(fileReference.data);
			stop();
			
			fileReference.data.clear(); // clear bytes data 
		}
		
		/**
		 * Handle io Error
		 * 
		 * 
		 * @param event
		 */ 
		private function handleIOError(event:IOErrorEvent):void
		{
			
		}
		
	}
}