package com.gran.ui.menus
{
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.NumericStepper;
	
	/**
	 * MenuStepper.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class MenuStepper extends NumericStepper
	{
		public function MenuStepper()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
		}
		
		/**
		 * @private lastValue
		 */ 
		protected var lastValue:Number;
		
		/**
		 * InitComponents
		 */ 
		protected function initComponents():void
		{
			if (textDisplay) {
				textDisplay.addEventListener(KeyboardEvent.KEY_UP, handleTextDisplayKeyUp);
				textDisplay.addEventListener(FocusEvent.FOCUS_OUT, handleTextDisplayFocusOut);
			}
			validateValue();
		}
		
		protected function validateValue():void
		{
			if (!isNaN(value)) {
				lastValue = value;
			}
			else {
				value = lastValue;
			}
			
		}
		
		/**
		 * Handle text display key up
		 * 
		 * @param event
		 */ 
		protected function handleTextDisplayKeyUp(event:KeyboardEvent):void
		{
			validateValue();
		}
		
		/**
		 * Handle text display focus out
		 * 
		 * @param event
		 */ 
		protected function handleTextDisplayFocusOut(event:FocusEvent):void
		{
			validateValue();
		}
		
		/**
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		protected function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			initComponents();
		}
	}
}