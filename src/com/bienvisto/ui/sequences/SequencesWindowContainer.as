package com.bienvisto.ui.sequences
{
	import com.bienvisto.elements.sequences.Sequence;
	import com.bienvisto.util.sprintf;
	
	import mx.controls.ProgressBar;
	import mx.events.CloseEvent;
	
	import spark.components.Label;
	import spark.components.TitleWindow;
	
	
	/**
	 * SequencesWindowContainer
	 * 	This is the code behind controller class for the SequencesWindow.mxml
	 * 
	 * @author Cristobal Dabed
	 * @versio {{VERSION_NUMBER}}
	 */ 
	public class SequencesWindowContainer extends TitleWindow
	{
		public function SequencesWindowContainer()
		{
			super();
			
			addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
		/**
		 * @public
		 */		
		public var totalSent:Label;
		
		/**
		 * @public
		 */		
		public var totalRecv:Label;
		
		/**
		 * @public
		 */		
		public var lastSeqNumSent:Label;
		
		/**
		 * @public
		 */ 
		public var lastSeqNumRecv:Label;
		
		/**
		 * @public
		 */ 
		public var percRecv:Label
		
		/**
		 * @public
		 */ 
		public var progressBar:ProgressBar;
		
		/**
		 * Update 
		 * 
		 * @param sent
		 * @param recv
		 */ 
		public function update(sent:Vector.<Sequence>, recv:Vector.<Sequence>):void
		{
			if (sent) {
				if (sent.length > 0) {
					totalSent.text = String(sent.length);
					lastSeqNumSent.text = String(sent[sent.length - 1].seqNum);
				}
			}
			
			if (recv) {
				if (recv.length > 0) {
					totalRecv.text = String(recv.length);
					lastSeqNumRecv.text = String(recv[recv.length - 1].seqNum);
				}				
			}
			
			if (sent && recv) {
				if (sent.length > 0 && recv.length > 0) {
					var st:Number = sent.length;
					var rt:Number = recv.length;
					var value:Number = 100;
					if (rt < st) {
						value = 100 * rt / st;
					}
					
					
					percRecv.text = sprintf("%0.2f %s", value, "%");
					progressBar.setProgress(value, 100);
				}
			}
		}
		
		/**
		 * Handle close
		 * 
		 * @param event
		 */ 
		private function handleClose(event:CloseEvent):void
		{
			visible = false;
		}
	}
}