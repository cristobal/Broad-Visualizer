package com.bienvisto.UIComponents {

	import flash.events.Event;
	
	import spark.components.Label;
	import spark.components.Group;
	
	import mx.core.UIComponent;

	public class Grid extends Group
	{
		public static const THIN_LINE_COLOR:uint = 0xE6F8FF;
		public static const THICK_LINE_COLOR:uint = 0xD4EDFF;

		public var spacing:int = 20;

		protected var scale_:Number = 1.0; // Default is one pixel = one meter
		protected var parentWidth:int;
		protected var parentHeight:int;
		
		protected var label:Label;

		public function Grid()
		{
			label = new Label();
			addElement(label);
			
			addEventListener("creationComplete", init);
		}

		public function set scale(newValue:Number):void
		{
			scale_ = newValue;
			updateGraphics();
		}

		protected function init(e:Event):void
		{
			updateGraphics();
			
			parent.addEventListener(Event.RESIZE, parentResized);
		}

		protected function parentResized(e:Event):void
		{
			updateGraphics();
		}


		protected function updateGraphics():void
		{
			parentWidth = parent.width;
			parentHeight = parent.height;
			
			graphics.clear();
			drawGridLines();
			drawScale();
		}


		protected function drawScale():void
		{
			graphics.lineStyle(2, 0x696969);
			
			var scaleY:int = (Math.floor(parentHeight/spacing)-3)*spacing;
			graphics.moveTo(spacing, scaleY);
			graphics.lineTo(6*spacing, scaleY);
			
			graphics.lineStyle(1, 0x696969);
			graphics.lineTo(6*spacing, scaleY - 4);
			
			label.text = Math.round(100/scale_).toString() + " meters";
			label.setStyle("textAlign", "center");
			label.x = 6*spacing - 30;
			label.y = scaleY - 15;
		}


		protected function drawGridLines():void
		{
			// Draw horizontal lines
			var currentPosition:int = 0;
			var lineNumber:int = -1;
			while (currentPosition < parentHeight)
			{
				if (lineNumber % 5 == 0)
					graphics.lineStyle(1, THICK_LINE_COLOR);
				else
					graphics.lineStyle(1, THIN_LINE_COLOR);
				graphics.moveTo(0, currentPosition);
				graphics.lineTo(parentWidth, currentPosition);
				currentPosition += spacing;
				lineNumber++;
			}
			
			currentPosition = 0;
			lineNumber = -1;
			// Draw vertical lines
			while (currentPosition < parentWidth)
			{
				if (lineNumber % 5 == 0)
					graphics.lineStyle(1, THICK_LINE_COLOR);
				else
					graphics.lineStyle(1, THIN_LINE_COLOR);
				graphics.moveTo(currentPosition, 0);
				graphics.lineTo(currentPosition, parentHeight);
				currentPosition += spacing;
				lineNumber++;
			}
		}
		
	}
}
