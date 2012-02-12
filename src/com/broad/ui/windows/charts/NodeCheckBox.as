package com.broad.ui.windows.charts
{
	import flash.events.Event;
	
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.Label;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * NodeCheckBox.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeCheckBox extends Group
	{
		public function NodeCheckBox(nodeID:int)
		{
			super();
			width  = 50;
			height = 20;
			_nodeID = nodeID;
			setup();
		}
		
		/**
		 * @private
		 */ 
		private var checkbox:CheckBox;
		
		/**
		 * @private
		 */ 
		private var _nodeID:int;
		
		/**
		 * @readonly nodeID
		 */ 
		public function get nodeID():int
		{
			return _nodeID;
		}
		
		/**
		 * @readwrite selected
		 */ 
		public function get selected():Boolean
		{
			return checkbox.selected;
		}
		
		public function set selected(value:Boolean):void
		{
			checkbox.selected = value;
		}

		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			checkbox = new CheckBox();
			checkbox.setStyle("top", 2);
			checkbox.addEventListener(Event.CHANGE, handleChangeEvent);
			
			addElement(checkbox);
			
			var label:Label = new Label();
			label.text = "#" + String(nodeID);
			label.setStyle("color", "0xFAFAFA");
			label.setStyle("fontFamily", "DejaVuSansMono");
			label.setStyle("fontSize", "13");
			label.setStyle("top", 6);
			label.setStyle("left", 18);
			addElement(label);
		}
		
		/**
		 * Handle change event
		 * 
		 * @param event
		 */ 
		private function handleChangeEvent(event:Event):void
		{
			dispatchEvent(event); // forwarde the event
		}
	}
}