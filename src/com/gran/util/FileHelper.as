package com.gran.util
{

	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;

	/**
	 * User Interface Helper: 
	 * Auxiliary class used to help with some complex processes related to the
	 * user interface, like loading a file from the user's hard drive
	 */
	public class FileHelper
	{
	
		/**
		 * Reference to the trace file to be loaded.
		 */
		protected var traceFile_:FileReference;
		
		/**
		 * Function to be called when the load of a file is complete
		 */
		protected var loadCompleteCallback_:Function;



		/**
		 * Opens a browser that the user can use to select the trace file
		 * and prepares everything to load that file
		 *
		 * @param callback Function to be called when the file is loaded. Must accept a String parameter
		 */
		public function browseFile(callback:Function):void
		{
			traceFile_ = new FileReference();
			traceFile_.addEventListener(Event.SELECT, fileSelected);
			traceFile_.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			traceFile_.addEventListener(Event.COMPLETE, loadComplete);

			loadCompleteCallback_ = callback;
			
			traceFile_.browse();
		}


		/**
		 * Called when the user has selected a file and starts to load it
		 */
		protected function fileSelected(e:Event):void
		{
			var file:FileReference = FileReference(e.target);
			file.load();
		}

		/**
		 * Called when the file is completely loaded
		 */
		protected function loadComplete(e:Event):void
		{
			loadCompleteCallback_(traceFile_.data as ByteArray);
		}

		/**
		 * Called if there is an error loading the file
		 */
		protected function loadError(e:ErrorEvent):void
		{
			Tools.log(e.text as String, Tools.LOG_LEVEL_ERROR);
		}

	}
}
