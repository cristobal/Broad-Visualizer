package com.bienvisto.ui.sequences
{
	import com.bienvisto.elements.sequences.Sequence;
	import com.bienvisto.elements.sequences.SequencesContainer;
	import com.bienvisto.elements.sequences.SequencesRecv;
	import com.bienvisto.elements.sequences.SequencesSent;
	import com.bienvisto.util.sprintf;
	import com.bienvisto.view.drawing.NodeDrawingManager;
	
	import flash.events.Event;
	
	import mx.controls.ProgressBar;
	import mx.events.CloseEvent;
	
	import spark.components.Label;
	import spark.components.TitleWindow;
	
	
	/**
	 * SequencesWindowContainer
	 * 	This is the code behind controller class for the SequencesWindow.mxml
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class SequencesWindowContainer extends TitleWindow
	{
		public function SequencesWindowContainer()
		{
			super();
			addEventListener(CloseEvent.CLOSE, handleClose);
			
			updateTime = NodeDrawingManager.DRAW_UPDATE_TIME;
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
		 * @private
		 */ 
		private var updateTime:uint;
		
		/**
		 * @private
		 */ 
		private var elapsed:uint = 0;
		
		/**
		 * @private
		 */ 
		private var sequencesContainer:SequencesContainer;
		
		/**
		 * Set sequences container
		 * 
		 * @param sequencesContainer
		 */ 
		public function setSequencesContainer(sequencesContainer:SequencesContainer):void
		{
			this.sequencesContainer = sequencesContainer;
			
			this.sequencesContainer.sources.addEventListener(Event.CHANGE, handleSourcesChange);
			this.sequencesContainer.destinations.addEventListener(Event.CHANGE, handleDestinationsChange);
		}
		
		/**
		 * @pverride
		 */ 
		override public function set visible(value:Boolean):void 
		{
			var flag:Boolean = !visible && value;
			super.visible = value;
			if (flag) {
				update();
			}
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint;
		
		/**
		 * @readwrite time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		/**
		 * Set time
		 * 
		 * @param time
		 */ 
		public function setTime(value:uint):void
		{
			_time = value;
			if (elapsed != time) {
				elapsed = time;
				
				// only update around 1/3 second or every 300ms.
				if ((time % updateTime) == 0) { 
					invalidate();
				}
			}
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			if (visible) {
				update();
			}
		}
		
		/**
		 * Toggle
		 */ 
		public function toggle():void
		{
			visible = !visible;
		}
		
		/**
		 * Update 
		 * 
		 * @param sent
		 * @param recv
		 */ 
		public function update():void
		{
			if (!sequencesContainer || !initialized) {
				return;
			}
			
/*			if (sent) {
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
			}*/
		}
		
		/**
		 * Handle source change
		 * 
		 * @param event
		 */ 
		private function handleSourcesChange(event:Event):void
		{
			
		}
		
		/**
		 * Handle destunations change
		 * 
		 * @param event
		 */ 
		private function handleDestinationsChange(event:Event):void
		{
			
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