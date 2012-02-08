package com.bienvisto.ui.windows.charts
{
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.util.Tools;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.utils.ObjectProxy;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Path;
	
	/**
	 * ChartLabel.as 
	 *
	 * Graphic component that represents the label of a variable in the 
	 * StatsWindow. Also has a "close" button which removes the variable from
	 * the cart
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */
	public final class ChartLabel extends BorderContainer
	{
		
		/**
		 * Event dispatched when the user clicks on the "close" button
		 */
		[event(name="remove", type="flash.events.Event")]
		public static const REMOVE:String = "remove";
		
		
		/**
		 * @private
		 */ 
		private static var labelOffset:int = 17;
		
		/**
		 * Constructs a new VariableLabel object
		 *
		 * @param variableName Name of the variable
		 * @param color Color in which the variable is represented
		 */
		public function ChartLabel(item:Object, color:uint)
		{
			_item   = new ObjectProxy(item); 
			_color  = color;
			
			height = 18;
			
			setup();
		}
		
		/**
		 * @private
		 */ 
		private var label:Label;
		
		/**
		 * Name of the associated variable
		 */
		private var _item:Object;
		
		/**
		 * @readonly provider
		 */ 
		public function get item():Object
		{
			return _item;
		}
		
		/**
		 * Name of the associated variable
		 */
		private var _color:uint;
		
		/**
		 * @readonly color
		 */ 
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * Initializes the graphics of this component. Basically, it is a
		 * colored rectangle containing a label (the name of the variable) and
		 * a close button to remove the variable from the chart
		 */
		private function setup():void
		{
			label= new Label();
			var closeButton:Label = new Label();
			
			label.text = item.label;
			label.setStyle("left", labelOffset);
			label.setStyle("top", 3);
			label.setStyle("fontSize", 12);
			label.addEventListener(FlexEvent.CREATION_COMPLETE, handleLabelCreationComplete);
			addElement(label);
			
			// Draw the close button
			closeButton.width = 15;
			closeButton.height = 15;
			closeButton.x = 0;
			closeButton.y = 0;
			closeButton.graphics.clear();
			closeButton.graphics.lineStyle(3, Tools.darkenColor(color, 0.2));
			closeButton.graphics.moveTo(5,5);
			closeButton.graphics.lineTo(10,10);
			closeButton.graphics.moveTo(5,10);
			closeButton.graphics.lineTo(10,5);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButtonClick);
			
			
			addElement(closeButton);
		}
		
		/**
		 * Handle label creation complete
		 * 
		 * @param event
		 */ 
		private function handleLabelCreationComplete(event:FlexEvent):void
		{
			width = labelOffset + label.measuredWidth + 10;
			setStyle("cornerRadius", 2);
			setStyle("backgroundColor", Tools.lightenColor(color, 0.8));
			setStyle("borderColor", Tools.lightenColor(color, 0.6));
		}
		
		/**
		 * Handle close button click
		 * 	Called when the remove button is clicked. Dispatches a new REMOVE
		 * 	event
		 * 
		 * @param event
		 */
		private function handleCloseButtonClick(event:MouseEvent):void
		{
			dispatchEvent(new Event(REMOVE));
		}
		
	}
}

