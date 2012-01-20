package com.bienvisto.view.components
{
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.view.drawing.IDrawingManager;
	import com.bienvisto.view.drawing.NodeDrawingManager;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	[Event(name="selected", type="com.bienvisto.view.events.NodeSpriteEvent")]
	
	/**
	 * NodeView.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeView extends ViewComponent
	{
		public function NodeView(container:NodeContainer)
		{
			super();
			
			this.container = container;	
		}
		
		/**
		 * @private
		 */ 
		private var lastTime:uint;
		
		/**
		 * @private
		 */ 
		private var container:NodeContainer;
		
		
		/**
		 * @private
		 */ 
		private var nodeSprites:Vector.<NodeSprite> = new Vector.<NodeSprite>();
		
		/**
		 * @private
		 */ 
		private var managers:Vector.<NodeDrawingManager> = new Vector.<NodeDrawingManager>();
		
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
		 * Add drawing manager
		 * 
		 * @param item
		 */ 
		public function addDrawingManager(item:NodeDrawingManager):void
		{
			managers.push(item);
			item.addEventListener(Event.CHANGE, handleNodeDrawingManagerChange);
		}
		
		/**
		 * Remove drawing manager
		 * 
		 * @param item
		 */ 
		public function removeDrawingManager(item:NodeDrawingManager):void
		{
			var manager:NodeDrawingManager;
			for (var i:int = managers.length; i--;) {
				manager = managers[i];
				if (manager === item) {
					item.removeEventListener(Event.CHANGE, handleNodeDrawingManagerChange);
					managers.splice(i, 1);
					break;
				}
			}
		}
		
		private var count:int = 0;
		private var mod:int   = 10;
		
		/**
		 * Check nodes
		 */ 
		private function checkNodes():void
		{
			if ((count % mod) == 0) {
				
				var nodes:Vector.<Node> = container.nodes;
				var flag:Boolean;
				var node:Node, nodeSprite:NodeSprite;
				
				// Add new nodes
				for (var i:int = 0, l:int = nodes.length; i < l; i++) {
					node = nodes[i];
					flag = true;
					for (var j:int = 0, n:int = nodeSprites.length; j < n;j++) {
						nodeSprite = nodeSprites[j];
						if (nodeSprite.node.id == node.id) {
							flag = false;
							break;
						}
					}
					
					if (flag) {
						nodeSprite = new NodeSprite(node);
						nodeSprite.addEventListener(NodeSpriteEvent.SELECTED, handleNodeSpriteSelected);
						nodeSprites.push(nodeSprite);
						addChild(nodeSprite);
					}	
				}
				
				// Remove nodes that no longer are in use
				for (i = nodeSprites.length; i--;) {
					nodeSprite = nodeSprites[i];
					flag = true;
					for (j = 0, n = nodes.length; j < n; j++) {
						node = nodes[j];
						if (node.id == nodeSprite.node.id) {
							flag = false;
							break;
						}
					}
					
					if (flag) {
						nodeSprites.splice(i, 1);
						nodeSprite.removeEventListener(NodeSpriteEvent.SELECTED, handleNodeSpriteSelected);
						removeChild(nodeSprite);						
						nodeSprite.destroy();
						nodeSprite = null;
					}
				}
				
				count = 0;
			}
			
			count++;
		}
		
		/**
		 * Update selected
		 * 
		 * @param nodeSprite
		 */ 
		private function updateSelected(nodeSprite:NodeSprite):void
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
					_selectedNodeSprite.selectedOrder = -1;
					_selectedNodeSprite.selected = false;
					_selectedNodeSprite = null;
				}
			}
			else if (_selectedNodeSprite && _selectedNodeSprite2) {
				// 
				if (isSameNodeSprite(_selectedNodeSprite, nodeSprite)) {
					_selectedNodeSprite.selectedOrder = -1;
					_selectedNodeSprite.selected = false;
					_selectedNodeSprite = null;
					
					// swap node sprites
					_selectedNodeSprite = _selectedNodeSprite2;
					_selectedNodeSprite.selectedOrder = 1;
					_selectedNodeSprite2 = null;
				}
				else if (isSameNodeSprite(_selectedNodeSprite2, nodeSprite)) {
					// remove selected node sprite
					_selectedNodeSprite2.selectedOrder = -1;
					_selectedNodeSprite2.selected = false;
					_selectedNodeSprite2 = null;
				}
				else {
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
		 * Is same node
		 * 
		 */ 
		private function isSameNodeSprite(node:NodeSprite, node2:NodeSprite):Boolean
		{
			return node.node.id == node2.node.id;
		}
		
		/**
		 * @override
		 */ 
		override public function update(time:uint):void
		{
			checkNodes();
			
			var manager:NodeDrawingManager;
			for (var i:int = 0, l:int = managers.length; i < l; i++) {
				manager = managers[i];
				manager.update(time, nodeSprites);
			}
			
			var nodeSprite:NodeSprite;
			for (i = 0, l = nodeSprites.length; i < l; i++) {
				nodeSprite = nodeSprites[i];
				nodeSprite.update(time);
				// nodeSprite.invalidate();
			}
			
			lastTime = time;
		}
		
		/**
		 * @override
		 */ 
		override protected function invalidateScale():void
		{
			super.invalidateScale();
			var manager:NodeDrawingManager;
			for (var i:int = 0, l:int = managers.length; i < l; i++) {
				manager = managers[i];
				manager.scale = scale;
			}
		}
		
		/**
		 * Handle sprite selected
		 * 
		 * @param event
		 */ 
		private function handleNodeSpriteSelected(event:NodeSpriteEvent):void
		{
			updateSelected(event.nodeSprite);
			dispatchEvent(event); // forward event	
		}
		
		/**
		 * Handle node drawing manager change
		 * 
		 * @param event
		 */ 
		private function handleNodeDrawingManagerChange(event:Event):void
		{
			update(lastTime);
		}
		
	}
}