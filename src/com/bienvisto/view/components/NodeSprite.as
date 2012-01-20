package com.bienvisto.view.components
{
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[Event(name="selected", type="com.bienvisto.view.events.NodeSpriteEvent")]
	
	/**
	 * NodeSprite.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeSprite extends Sprite
	{
		
		//--------------------------------------------------------------------------
		//
		// Class variables
		//
		//-------------------------------------------------------------------------
		/**
		 * @private
		 */ 
		private static var selectedColor:uint 	 = 0xFF6622; // 0x00bf00; 
		
		/**
		 * @private
		 */ 
		private static var selectedColorSecond:uint = 0x43C8Ef; //0xA82015;// 0xFFF94A; // 0x00bf00; 
		
		/**
		 * @private
		 */
		private static var fillColor:uint 		 = 0x545454;
		
		/**
		 * @private
		 */
		private static var highlightedColor:uint = 0xFFF94A;
		
		/**
		 * @private
		 */
		private static var defaultRadius:uint = 10;
		
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		public function NodeSprite(node:Node)
		{
			super();
			setup();
			
			_node = node;
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		/**
		 * @private
		 */ 
		private var dirty:Boolean = false;
		
		/**
		 * @private
		 */
		private var color:uint = fillColor;
		
		/**
		 * @private
		 */
		private var shape:Shape;
		
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------------
		/**
		 * @readonly cx
		 */ 
		public function get cx():Number
		{
			return radius;
		}
		
		/**
		 * @readonly cy
		 */		
		public function get cy():Number
		{
			return radius;
		}
		
		/**
		 * @private radius
		 */
		private var _radius:uint = defaultRadius;
		
		/**
		 * @readonly radius
		 */
		public function get radius():uint
		{
			return _radius;
		}
		
		/**
		 * @private
		 */ 
		private var _selected:Boolean = false;
		
		/**
		 * @readwrite selected
		 */ 
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			invalidate();
		}
		
		/**
		 * @private
		 */ 
		private var _selectedOrder:int = 1;
		
		/**
		 * @readwrite selectedOrder
		 */ 
		public function get selectedOrder():int
		{
			return _selectedOrder;
		}
		
		public function set selectedOrder(value:int):void
		{
			_selectedOrder = value;
		}
		
		/**
		 * @private
		 */ 
		private var _node:Node;
		
		/**
		 * @readonly node
		 */ 
		public function get node():Node
		{
			return _node;	
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		public function setup():void
		{
			shape = new Shape();
			addChild(shape);
			
			draw();
			
			useHandCursor = true;
			mouseChildren = true;
			addEventListener(MouseEvent.CLICK, handleClick);
		}
		
		/**
		 * Draw
		 */ 
		private function draw():void
		{
			// cacheAsBitmap = false;
			shape.graphics.clear();
			shape.graphics.beginFill(color);
			
			var cx:Number = radius;
			var cy:Number = radius;
			graphics.moveTo(cx, cy);
			
			if (selected) {
				var color:uint = selectedColor;
				if (selectedOrder == 2) {
					color = selectedColorSecond;
				}
				shape.graphics.lineStyle(3, color);
			}
			
			shape.graphics.drawCircle(cx, cy, radius);
			shape.graphics.endFill();
			
			// cacheAsBitmap = true;
		}
		
		
		/**
		 * Set highlighted
		 * 
		 * @param color
		 */ 
		public function setHighlighted(color:uint = 0xFFF94A):void
		{
			this.color = color;
			this.dirty = true;
			// invalidate();
		}
		
		/**
		 * Invalidate
		 */ 
		public function invalidate():void
		{
			// NOTE: Add more logic here if needed	
			draw();
			color = fillColor;
		}
		
		/**
		 * Update
		 */ 
		public function update(time:uint):void
		{
			if (dirty) {
				invalidate();
				dirty = false;
			}
		}
		
		/**
		 * Destoy
		 * 	Clean up and remove resources
		 */ 
		public function destroy():void
		{
			removeEventListener(MouseEvent.CLICK, handleClick);
		}
		
		/**
		 * Handle click
		 * 
		 * @param event
		 */ 
		private function handleClick(event:MouseEvent):void
		{
			//trace("Clicked on node with id", node.id);
			selected = !selected;
			dispatchEvent(new NodeSpriteEvent(NodeSpriteEvent.SELECTED, false, false, this));
		}
		
	}
}