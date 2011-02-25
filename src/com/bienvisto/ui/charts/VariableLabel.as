package com.bienvisto.ui.charts
{
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.components.Group;
	import spark.primitives.Path;
	import spark.layouts.HorizontalLayout;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import com.bienvisto.core.Tools;


	/**
	 * Graphic component that represents the label of a variable in the 
	 * StatsWindow. Also has a "close" button which removes the variable from
	 * the cart
	 */
	public class VariableLabel extends BorderContainer
	{
		/**
		 * Event dispatched when the user clicks on the "close" button
		 */
		public static const REMOVE:String = "remove";
		
		/**
		 * Name of the associated variable
		 */
		protected var name_:String;
		/**
		 * Color assigned to this variable
		 */
		protected var color_:uint;
		
		/**
		 * Constructs a new VariableLabel object
		 *
		 * @param variableName Name of the variable
		 * @param color Color in which the variable is represented
		 */
		public function VariableLabel(variableName:String, color:uint)
		{
			name_ = variableName;
			color_ = color;
			
			this.width = 130;
			this.height = 18;
			
			initGraphics();
		}
		
		
		/**
		 * The name of the associated variable
		 */
		public function get varName():String
		{
			return name_;
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
			
			label.text = name_;
			label.setStyle("left", 17);
			label.setStyle("top", 5);
			
			// Draw the close button
			closeButton.width = 15;
			closeButton.height = 15;
			closeButton.x = 0;
			closeButton.y = 0;
			closeButton.graphics.clear();
			closeButton.graphics.lineStyle(3, Tools.darkenColor(color_, 0.2));
			closeButton.graphics.moveTo(5,5);
			closeButton.graphics.lineTo(10,10);
			closeButton.graphics.moveTo(5,10);
			closeButton.graphics.lineTo(10,5);
			
			closeButton.addEventListener(MouseEvent.CLICK, removeClicked);
			
			this.setStyle("cornerRadius", 2);
			this.setStyle("backgroundColor", Tools.lightenColor(color_, 0.8));
			this.setStyle("borderColor", Tools.lightenColor(color_, 0.6));
			this.addElement(closeButton);
			this.addElement(label);
		}
		
		
		/**
		 * Called when the remove button is clicked. Dispatches a new REMOVE
		 * event
		 */
		protected function removeClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(REMOVE));
		}
	}
}

