package com.bienvisto.ui.windows.charts
{
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.util.Tools;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Path;

	/**
	 * DataProviderLabel.as 
	 *
	 * Graphic component that represents the label of a variable in the 
	 * StatsWindow. Also has a "close" button which removes the variable from
	 * the cart
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */
	public final class DataProviderLabel extends BorderContainer
	{
		/**
		 * Event dispatched when the user clicks on the "close" button
		 */
		[event(name="remove", type="flash.events.Event")]
		public static const REMOVE:String = "remove";
		
		/**
		 * Constructs a new VariableLabel object
		 *
		 * @param variableName Name of the variable
		 * @param color Color in which the variable is represented
		 */
		public function DataProviderLabel(dataProvider:AggregateDataProvider)
		{
			_provider = dataProvider;
			
			width  = 130;
			height = 18;
			
			initGraphics();
		}
		
		/**
		 * Name of the associated variable
		 */
		private var _provider:AggregateDataProvider;
		
		/**
		 * @readonly provider
		 */ 
		public function get provider():AggregateDataProvider
		{
			return _provider;
		}
		
		/**
		 * Initializes the graphics of this component. Basically, it is a
		 * colored rectangle containing a label (the name of the variable) and
		 * a close button to remove the variable from the chart
		 */
		protected function initGraphics():void
		{
			var label:Label = new Label();
			var closeButton:Label = new Label();
			
			label.text = _provider.name;
			label.setStyle("left", 17);
			label.setStyle("top", 3);
			label.setStyle("fontSize", 12);
			
			var color:uint = _provider.color;
			
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
			
			setStyle("cornerRadius", 2);
			setStyle("backgroundColor", Tools.lightenColor(color, 0.8));
			setStyle("borderColor", Tools.lightenColor(color, 0.6));
			addElement(closeButton);
			addElement(label);
		}
		
		/**
		 * Called when the remove button is clicked. Dispatches a new REMOVE
		 * event
		 */
		protected function handleCloseButtonClick(event:MouseEvent):void
		{
			dispatchEvent(new Event(REMOVE));
		}
	}
}

