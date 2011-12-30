package com.bienvisto.view.components
{
	import mx.core.UIComponent;
	
	/**
	 * ViewComponents.as
	 * 	Abstract class for views that contains interaction or interactive shapes 
	 *  that are to be added to the visualizer view.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class ViewComponent extends UIComponent
	{
		public function ViewComponent()
		{
			super();
		}
		
		/**
		 * Update
		 * 	Gets called from the parent class on enter frame.
		 *  All subclasses should do their drawing and/or manipulation of child display object 
		 *  when this method get's called.
		 * 
		 * @param time
		 */ 
		public function update(time:uint):void
		{
			throw(new Error("Subclass must override the update method"));
		}
	}
}