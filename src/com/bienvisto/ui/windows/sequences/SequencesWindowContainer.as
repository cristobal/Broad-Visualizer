package com.bienvisto.ui.windows.sequences
{
	import com.bienvisto.elements.sequences.Sequence;
	import com.bienvisto.elements.sequences.SequencesContainer;
	import com.bienvisto.elements.sequences.SequencesRecv;
	import com.bienvisto.elements.sequences.SequencesSent;
	import com.bienvisto.ui.windows.BaseWindow;
	import com.bienvisto.util.sprintf;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	
	/**
	 * SequencesWindowContainer
	 * 	This is the code behind controller class for the SequencesWindow.mxml
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class SequencesWindowContainer extends BaseWindow
	{
		public function SequencesWindowContainer()
		{
			super();
			
			clampTimeValue = 500;
		}
		
		/**
		 * @public
		 */ 
		public var sourceValue:Label;
		
		/**
		 * @public
		 */		
		public var sourceSent:Label;
		
		/**
		 * @public
		 */ 
		public var sourceUnique:Label;
		
		/**
		 * @public
		 */		
		public var sourceLastSeqNum:Label;
		
		/**
		 * @public
		 */ 
		public var sourceAvgRate:Label;
		
		/**
		 * @public
		 */ 
		public var destValue:Label;
		
		/**
		 * @public
		 */		
		public var destRecv:Label;
		
		/**
		 * @public
		 */ 
		public var destDropped:Label;
		
		/**
		 * @public
		 */ 
		public var destLastSeqNum:Label;
		
		/**
		 * @public
		 */ 
		public var destAvgRate:Label;

		/**
		 * @public
		 */ 
		public var destAvgTimeRecv:Label;
		
		/**
		 * @public
		 */ 
		public var percLabel:Label;
		
		/**
		 * @private
		 */ 
		private var clampTimeValue:uint;
		
		/**
		 * @private
		 */ 
		private var lastUpdateTime:uint = 0;
		
		/**
		 * @private
		 */ 
		private var elapsed:uint = 0;
		
		/**
		 * @private
		 */ 
		public var progressGroup:Group;

		/**
		 * @private
		 */ 
		private var progressBarBackground:UIComponent; 
		
		/**
		 * @private
		 */ 
		private var progressBarContent:UIComponent; 
		
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
			this.sequencesContainer.sent.addEventListener(Event.INIT, handleSourceInit);
			this.sequencesContainer.recv.addEventListener(Event.INIT, handleDestInit);
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
			
			elapsed = value - (value % clampTimeValue);
			// only invalidate around 1/2 second or every 500ms.
			if (elapsed != lastUpdateTime) {
				lastUpdateTime = elapsed;
				invalidate();
			}
		}
		
		/**
		 * @override
		 */ 
		override protected function setup():void
		{

			super.setup();
			updateSources();
			update();
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
			
			// #Source metrics
			sourceSent.text   = String(sequencesContainer.sent.sampleSourceTotal(elapsed));
			var unique:int    = sequencesContainer.sent.sampleSourceUnique(elapsed);
			sourceUnique.text = String(unique);
			
			var value:int         = sequencesContainer.sent.sampleSourceLastSeqNum(elapsed);
			sourceLastSeqNum.text = (value < 0 ? "–" : String(value));
			sourceAvgRate.text    = String(sequencesContainer.sent.sampleSourceRate(elapsed));
			
			
			// #Destination metrics
			var recv:int     = sequencesContainer.recv.sampleDestTotal(elapsed);
			destRecv.text    = String(recv);
			destDropped.text = String(sequencesContainer.recv.sampleDestDrops(elapsed));
			
			value			     = sequencesContainer.recv.sampleDestLastSeqNum(elapsed);
			destLastSeqNum.text  = (value < 0 ? "–" : String(value));
			destAvgRate.text     = String(sequencesContainer.recv.sampleDestRate(elapsed));
			
			value				 = sequencesContainer.recv.sampleDestTime(elapsed);
			if (value < 1000) {
				destAvgTimeRecv.text = String(value) + " ms";
			}
			else {
				value = value / 1000;
				
				var minutes:int = Math.floor(value / 60);
				value -= minutes * 60;
				
				destAvgTimeRecv.text = sprintf("%02d:%02d mm:ss", minutes, value);
			}
			
			
			var perc:Number = (recv / unique);
			percLabel.text = sprintf("%d of %d sequences (%d %%)", recv, unique, int(Math.floor(perc * 100)));
			updateProgress(unique, recv, perc, sequencesContainer.recv.sampleDestRecv(elapsed, true));
		}
		
		/**
		 * Update progress
		 * 
		 * @param sent
		 * @param recv
		 * @param perc
		 * @param sequences
		 */ 
		private function updateProgress(sent:int, recv:int, perc:Number, sequences:Vector.<Sequence> = null):void
		{
			
			if (!progressBarBackground) {
				addProgressBarBackground();	
			}
			
			if (int(perc * 100) == 0) {
				if (progressBarContent) {
					progressGroup.removeElement(progressBarContent);
					progressBarContent = null;
				}
				return;
			}
			if (perc > 1) {
				perc = 1;
			}
			
			var component:UIComponent = new UIComponent();
			var graphics:Graphics     = component.graphics;
			var matrix:Matrix;
			var w:int = 378;
			var h:int = 12;
			
			/* -- Draw as percentage bar -- */
			// draw top border
			graphics.beginFill(0x5695C8);
			graphics.drawRect(0, 0, w * perc, 1);
			graphics.endFill();
			
			// draw fill
			graphics.beginFill(0x69B6F4);
			graphics.drawRect(1, 1, (w - 2) * perc, 4);
			graphics.endFill();
			
			matrix = new Matrix();
			matrix.createGradientBox(1, 5, (Math.PI / 180) * 90, 0, 0);
			
			// Left border
			graphics.beginGradientFill(GradientType.LINEAR, [0x5695C8, 0x5491C3], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
			graphics.drawRect(0, 0, 1, 5);
			graphics.endFill();
			
			// Right border	
			if (perc == 1) {
				graphics.beginGradientFill(GradientType.LINEAR, [0x5695C8, 0x5491C3], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
				graphics.drawRect(w - 1, 0, 1, 5);
				graphics.endFill();
			}
			
			/* -- Draw as sequences bar -- */
			if (perc == 1) {
				
				// fill rect
				graphics.beginFill(0x3A95DC);
				graphics.drawRect(1, 5, w - 2, 6);
				graphics.endFill();
				
				// bottom border
				graphics.beginFill(0x3178B1);
				graphics.drawRect(0, 11, w, 1);
				graphics.endFill();
				
				matrix = new Matrix();
				matrix.createGradientBox(1, 7, (Math.PI / 180) * 90, 0, 0);
				
				// Left border
				graphics.beginGradientFill(GradientType.LINEAR, [0x3078B0, 0x3178B1], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
				graphics.drawRect(0, 5, 1, 7);
				graphics.endFill();
				
				// Right border	
				graphics.beginGradientFill(GradientType.LINEAR, [0x3078B0, 0x3178B1], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
				graphics.drawRect(w - 1, 5, 1, 7);
				graphics.endFill();
			}
			else if (sequences && sequences.length > 0) {
				var color:uint = 0x3A95DC;
				
				var length:Number = w - 2;
				var offset:int    = 1;
				
				var lastSeqNum:int;
				var seqNum:int;
				var start:int = -1, end:int = -1;
				var draw:Boolean;
				for (var i:int = 0, l:int = sequences.length; i < l; i++) {
					
					seqNum   = sequences[i].seqNum;
					if (start < 0) {
						start = seqNum;
					}
					else if (lastSeqNum + 1 < seqNum) {
						end  = lastSeqNum; // 
						draw = true;
					}
					else if (i + 1 == l) {
						end = seqNum;
						draw = true;
					}

					
					if (draw) {
						
						var distance:Number = (end - start);
						if (distance > 0) {
							// normalize values
							// start point
							// end point
							// drawing width
							var sp:Number = ((start / sent) * length) + offset; 
							var ep:Number = (end / sent) * length;
							var dw:Number = ep - sp;
							
							// fill rect
							graphics.beginFill(0x3A95DC);
							graphics.drawRect(sp, 5, dw, 6);
							graphics.endFill();
							
							// bottom border
							graphics.beginFill(0x3178B1);
							graphics.drawRect(sp, 11, dw, 1);
							graphics.endFill();
						}
						draw = false;
						if (i + 1 < l) {
							start = -1; // 
							i--;
						}
					}
					
					lastSeqNum = seqNum;
				}
				
				matrix = new Matrix();
				matrix.createGradientBox(1, 7, (Math.PI / 180) * 90, 0, 0);
				
				// Left border
				graphics.beginGradientFill(GradientType.LINEAR, [0x3078B0, 0x3178B1], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
				graphics.drawRect(0, 5, 1, 7);
				graphics.endFill();
				
				// Right border	
				if (perc == 1) {
					graphics.beginGradientFill(GradientType.LINEAR, [0x3078B0, 0x3178B1], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
					graphics.drawRect(w - 1, 5, 1, 7);
					graphics.endFill();
				}
			}
			
			if (progressBarContent) {
				progressGroup.removeElement(progressBarContent);
				progressBarContent = null;
			}
			component.y = 20;
			progressGroup.addElement(component);
			progressBarContent = component;
		}
		
		/**
		 * Add progress bar background
		 */ 
		private function addProgressBarBackground():void
		{
			var component:UIComponent = new UIComponent();
			var graphics:Graphics     = component.graphics;
			
			var w:int = 378;
			var h:int = 12;
			
			// Top border
			graphics.beginFill(0xc2c2c2);
			graphics.drawRect(0, 0, w, 1);
			graphics.endFill();
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(1, h, (Math.PI / 180) * 90, 0, 0);
			
			// Left border
			graphics.beginGradientFill(GradientType.LINEAR, [0xC3C3C3, 0xCDCDCD], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
			graphics.drawRect(0, 0, 1, h);
			graphics.endFill();
			
			// Right border
			graphics.beginGradientFill(GradientType.LINEAR, [0xC3C3C3, 0xCDCDCD], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
			graphics.drawRect(w - 1, 0, 1, h);
			graphics.endFill();
			
			// Bottom border
			graphics.beginFill(0xcccccc);
			graphics.drawRect(0, 11, w, 1);
			graphics.endFill();
			
			
			matrix = new Matrix();
			matrix.createGradientBox(w - 2, 4, (Math.PI / 180) * 90, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, [0xEEEEEE, 0xEFEFEF], [1,1], [0x00, 0xFF], matrix, SpreadMethod.REPEAT);
			graphics.drawRect(1, 1, w - 2, 4);
			graphics.endFill();
			
			component.y = 20;
			progressGroup.addElement(component);
			progressBarBackground = component;
		}
		
		/**
		 * Update sources
		 */ 
		private function updateSources():void
		{
			if (!sequencesContainer) {
				return;	
			}
			
			if (sequencesContainer.sent.sourceNode && sourceValue) {
				sourceValue.text = "#" + String(sequencesContainer.sent.sourceNode.id);
			}
			if (sequencesContainer.recv.destNode && destValue) {
				destValue.text  =  "#" + String(sequencesContainer.recv.destNode.id);
			}
		}
		
		/**
		 * Handle source change
		 * 
		 * @param event
		 */ 
		private function handleSourceInit(event:Event):void
		{
			updateSources();
		}
		
		/**
		 * Handle dest change
		 * 
		 * @param event
		 */ 
		private function handleDestInit(event:Event):void
		{
			updateSources();
		}
		
	}
}