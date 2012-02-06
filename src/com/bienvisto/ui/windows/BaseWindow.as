package com.bienvisto.ui.windows
{
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.TitleWindow;
	
	public class BaseWindow extends TitleWindow
	{
		public function BaseWindow()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
		/**
		 * Setup
		 */ 
		protected function setup():void
		{
			setStyle("skinClass", Class(BaseWindowSkin));
		}
		
		/**
		 * Toggle
		 */ 
		public function toggle():void
		{
			visible = !visible;
		}
		
		/**
		 * On close
		 */ 
		protected function onClose():void
		{
			visible = false;
		}
		
		/**
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		protected function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			setup();
		}
		
		/**
		 * Handle close
		 * 
		 * @param event
		 */ 
		protected function handleClose(event:CloseEvent):void
		{
			onClose();
		}
	}
}