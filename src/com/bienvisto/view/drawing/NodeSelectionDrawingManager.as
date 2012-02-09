package com.bienvisto.view.drawing
{
	import com.bienvisto.view.components.NodeSelectionSprite;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.ViewComponent;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[Event(name="selected", type="com.bienvisto.view.events.NodeSpriteEvent")]
	
	/**
	 * NodeSelectionDrawingManager.as
	 * 	Responsible for 
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class NodeSelectionDrawingManager extends NodeDrawingManager
	{
		public function NodeSelectionDrawingManager(view:ViewComponent)
		{
			super("Node Selection");
			setup(view);
		}
		
		/**
		 * @private
		 */ 
		private var view:ViewComponent;
		
		/**
		 * @private
		 */ 
		private var sprite:Sprite;
		
		/**
		 * @private
		 */ 
		private var dirty:Boolean;
		
		/**
		 * @private
		 */ 
		private var dirtyUnselect:Boolean
		
		/**
		 * @private
		 */ 
		private var nodeSelectionSprites:Vector.<NodeSelectionSprite>;
		
		/**
		 * @private
		 * 	The first selected node sprite
		 */ 
		private var _selectedNodeSprite:NodeSprite;
		
		/**
		 * @readonly selectedNodeSprite
		 */ 
		public function get selectedNodeSprite():NodeSprite
		{
			return _selectedNodeSprite;
		}
		
		/**
		 * @private
		 * 	The second selected node sprite
		 */ 
		private var _selectedNodeSprite2:NodeSprite;
		
		/**
		 * @readonly selectedNodeSprite2
		 */ 
		public function get selectedNodeSprite2():NodeSprite
		{
			return _selectedNodeSprite2;
		}
		
		/**
		 * Setup
		 * 
		 * @param view
		 */ 
		private function setup(view:ViewComponent):void
		{
			nodeSelectionSprites = new Vector.<NodeSelectionSprite>();
			
			sprite = new Sprite();
			var index:int = view.numChildren - 1;
			if (index < 0) {
				index = 0;
			}
			view.addChildAt(sprite, index);
			
			view.addEventListener(Event.ADDED, handleViewAdded);
			this.view = view;
		}
		
		/**
		 * @remove
		 */ 
		override public function reset():void
		{
			for (var i:int = nodeSelectionSprites.length; i--;) {
				removeNodeSprite(nodeSelectionSprites[i].nodeSprite);
			}
			
			nodeSelectionSprites = new Vector.<NodeSelectionSprite>();
		}
		
		/**
		 * Update selected from node selection sprite selected event
		 * 
		 * @param nodeSprite
		 */ 
		private function updateNodeSelectionSpriteSelected(nodeSprite:NodeSprite):void
		{
			
			if (!_selectedNodeSprite && !_selectedNodeSprite2) {
				_selectedNodeSprite = nodeSprite;
				_selectedNodeSprite.selectedOrder = 1;
				_selectedNodeSprite.selected      = true;
			}
			else if (_selectedNodeSprite && !_selectedNodeSprite2) {
				// set sprite 2
				if (!isSameNodeSprite(_selectedNodeSprite, nodeSprite)) {
					_selectedNodeSprite2 = nodeSprite;
					_selectedNodeSprite2.selectedOrder = 2;
					_selectedNodeSprite2.selected = true;
				}
					// remove selected sprite 1
				else {
					dirtyUnselect = true;
					
					_selectedNodeSprite.selectedOrder = -1;
					_selectedNodeSprite.selected = false;
					_selectedNodeSprite = null;
				}
			}
			else if (_selectedNodeSprite && _selectedNodeSprite2) {
				// 
				if (isSameNodeSprite(_selectedNodeSprite, nodeSprite)) {
					dirtyUnselect = true;
					
					_selectedNodeSprite.selectedOrder = -1;
					_selectedNodeSprite.selected = false;
					_selectedNodeSprite = null;
					
					// swap node sprites
					_selectedNodeSprite = _selectedNodeSprite2;
					_selectedNodeSprite.selectedOrder = 1;
					_selectedNodeSprite2 = null;
				}
				else if (isSameNodeSprite(_selectedNodeSprite2, nodeSprite)) {
					dirtyUnselect = true;
					
					// remove selected node sprite
					_selectedNodeSprite2.selectedOrder = -1;
					_selectedNodeSprite2.selected = false;
					_selectedNodeSprite2 = null;
					
				}
				else {
					dirtyUnselect = true;
					
					// swap selected node 2
					_selectedNodeSprite2.selectedOrder = -1;
					_selectedNodeSprite2.selected = false;
					_selectedNodeSprite2 = null;
					
					
					_selectedNodeSprite2 = nodeSprite;
					_selectedNodeSprite2.selectedOrder = 2;
					_selectedNodeSprite2.selected = true;
					
				}
			}
		}
		
		/**
		 * Update selected from node sprite selected event
		 * 
		 * @param nodeSprite
		 */ 
		private function updateNodeSpriteSelected(nodeSprite:NodeSprite):void
		{
			if (!nodeSprite.selected) {
				var flag:Boolean = false;
				
				if (selectedNodeSprite) {
					flag = isSameNodeSprite(selectedNodeSprite, nodeSprite);
				}
				if (selectedNodeSprite2 && !flag) {
					flag = isSameNodeSprite(selectedNodeSprite2, nodeSprite);
				}
				
				if (flag && !dirtyUnselect) {
					updateNodeSelectionSpriteSelected(nodeSprite); // remove selectedNodeSprite|selectedNodeSprite2 when selected status has changed from outside
				}
				else { 
					dirtyUnselect = true;
				}
			}
		}
		
		/**
		 * Is same node
		 * 
		 */ 
		private function isSameNodeSprite(node:NodeSprite, node2:NodeSprite):Boolean
		{
			return node.node.id == node2.node.id;
		}
		
		/**
		 * Add node sprite
		 * 
		 * @param nodeSprite
		 */ 
		public function addNodeSprite(nodeSprite:NodeSprite):void
		{
			var nodeSelectionSprite:NodeSelectionSprite = new NodeSelectionSprite(nodeSprite);
			nodeSelectionSprites.push(nodeSelectionSprite);
			nodeSelectionSprite.addEventListener(NodeSpriteEvent.SELECTED, handleNodeSelectionSpriteSelected);
			nodeSelectionSprite.nodeSprite.addEventListener(NodeSpriteEvent.SELECTED, handleNodeSpritedSelected);
			sprite.addChild(nodeSelectionSprite);
		}
		
		/**
		 * Remove node sprite
		 * 
		 * @param nodeSprite
		 */ 
		public function removeNodeSprite(nodeSprite:NodeSprite):void
		{
			var nodeSelectionSprite:NodeSelectionSprite;
			for (var i:int = nodeSelectionSprites.length; i--;) {
				nodeSelectionSprite = nodeSelectionSprites[i];
				if (nodeSelectionSprite.nodeSprite.node.id == nodeSprite.node.id) {
					sprite.removeChild(nodeSelectionSprite);
					if (nodeSelectionSprite.nodeSprite.selected) {
						nodeSelectionSprite.nodeSprite.selected = false;
					}
					nodeSelectionSprites.splice(i, 1);
					nodeSelectionSprite.nodeSprite.removeEventListener(NodeSpriteEvent.SELECTED, handleNodeSpritedSelected);
					nodeSelectionSprite.removeEventListener(NodeSpriteEvent.SELECTED, handleNodeSelectionSpriteSelected);
					nodeSelectionSprite.destroy();
					nodeSelectionSprite = null;
					break;
				}
			}
		}
		
		/**
		 * @override
		 */ 
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>, needsInvalidation:Boolean = false):void
		{
			for (var i:int = nodeSelectionSprites.length; i--;) {
				nodeSelectionSprites[i].invalidate();
			}
		}
		
		/**
		 *  Invalidate
		 */ 
		private function invalidateDisplayIndex():void
		{
			if (sprite && view && !dirty) {
				var index:int = view.getChildIndex(sprite);
				if (index < view.numChildren - 1) {
					index = view.numChildren - 1;
					view.addChildAt(sprite, index); // push to top				
				}
				dirty = true;
			}
			else {
				dirty = false;
			}
		}
		
		/**
		 * Handle view added
		 * 
		 * @param event
		 */ 
		private function handleViewAdded(event:Event):void
		{
			invalidateDisplayIndex();
		}
		
		/**
		 * Handle node sprite selected
		 * 
		 * @param event
		 */ 
		private function handleNodeSelectionSpriteSelected(event:NodeSpriteEvent):void
		{
			// update selected and forward event
			updateNodeSelectionSpriteSelected(event.nodeSprite);
			dispatchEvent(event);
		}
		
		/**
		 * Handle node sprite selected
		 * 
		 * @param event
		 */ 
		private function handleNodeSpritedSelected(event:NodeSpriteEvent):void
		{
			updateNodeSpriteSelected(event.nodeSprite);
		}
		
	}
}