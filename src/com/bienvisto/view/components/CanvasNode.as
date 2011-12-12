package com.bienvisto.view.components
{
	import com.bienvisto.elements.network.Node;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public final class CanvasNode extends Sprite
	{
		private static var fillColor:uint = 0x545454;
		private static var radius:uint = 10;
		
		public function CanvasNode(node:Node)
		{
			super();
			setup();
			
			_node = node;
		}
		private var _selected:Boolean = false;
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
		private var _node:Node;
		
		/**
		 * @readonly node
		 */ 
		public function  get node():Node
		{
			return _node;	
		}
		
		public function setup():void
		{
			draw();
			
			useHandCursor = true;
			mouseChildren = true;
			addEventListener(MouseEvent.CLICK, handleClick);
		}
		
		private function draw():void
		{
			// cacheAsBitmap = false;
			graphics.clear();
			graphics.beginFill(fillColor);
			
			var cx:Number = radius;
			var cy:Number = radius;
			// graphics.moveTo(cx, cy);
			
			if (selected) {
				
			}
			graphics.drawCircle(cx, cy, radius);
			graphics.endFill();
			
			// cacheAsBitmap = true;
		}
		
		private function invalidate():void
		{
			// NOTE: Add more logic here if needed
			
			draw();
		}
		
		/**
		 * Update
		 */ 
		public function update():void
		{
			// this.x = node.mobilityModel.getWaypoint(
		}
		
		/**
		 * Destoy
		 * 	Clean up and remove resources
		 */ 
		public function destroy():void
		{
			
		}
		
		
		private function handleClick(event:MouseEvent):void
		{
			trace("Clicked on node with id", node.id);
		}
	}
}