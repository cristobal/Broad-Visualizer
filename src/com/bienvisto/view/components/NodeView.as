package com.bienvisto.view.components
{
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.view.drawing.IDrawingManager;
	import com.bienvisto.view.drawing.NodeDrawingManager;
	import com.bienvisto.view.drawing.NodeSelectionDrawingManager;
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
			setup();
			
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
		private var nodeSelectionDrawingManager:NodeSelectionDrawingManager;
		
		/**
		 * @private
		 */ 
		private var managers:Vector.<NodeDrawingManager>;
		
		
		/**
		 * @private
		 */ 
		private var _nodeSprites:Vector.<NodeSprite>;
		
		/**
		 * @readonly nodeSprites
		 */ 
		public function get nodeSprites():Vector.<NodeSprite>
		{
			return _nodeSprites.concat();
		}
		
		/**
		 * @readwrite selectedNodeSprite
		 */ 
		public function get selectedNodeSprite():NodeSprite
		{
			return nodeSelectionDrawingManager.selectedNodeSprite;
		}
		
		/**
		 * @readwrite selectedNodeSprite2
		 */
		public function get selectedNodeSprite2():NodeSprite
		{
			return nodeSelectionDrawingManager.selectedNodeSprite2;	
		}
		
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			nodeSelectionDrawingManager = new NodeSelectionDrawingManager(this);
			_nodeSprites = new Vector.<NodeSprite>();
			managers    = new Vector.<NodeDrawingManager>();
			
			managers.push(nodeSelectionDrawingManager);
			nodeSelectionDrawingManager.addEventListener(NodeSpriteEvent.SELECTED, handleNodeSelectionDrawingManagerSelected);
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
					for (var j:int = 0, n:int = _nodeSprites.length; j < n;j++) {
						nodeSprite = _nodeSprites[j];
						if (nodeSprite.node.id == node.id) {
							flag = false;
							break;
						}
					}
					
					if (flag) {
						nodeSprite = new NodeSprite(node);
						_nodeSprites.push(nodeSprite);
						addChild(nodeSprite);
						
						nodeSelectionDrawingManager.addNodeSprite(nodeSprite);
					}	
				}
				
				// Remove nodes that no longer are in use
				for (i = _nodeSprites.length; i--;) {
					nodeSprite = _nodeSprites[i];
					flag = true;
					for (j = 0, n = nodes.length; j < n; j++) {
						node = nodes[j];
						if (node.id == nodeSprite.node.id) {
							flag = false;
							break;
						}
					}
					
					if (flag) {
						_nodeSprites.splice(i, 1);
						removeChild(nodeSprite);						
						nodeSelectionDrawingManager.removeNodeSprite(nodeSprite);
						
						nodeSprite.destroy();
						nodeSprite = null;
					}
				}
				
				count = 0;
			}
			
			count++;
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
				manager.update(time, _nodeSprites);
			}
			
			var nodeSprite:NodeSprite;
			for (i = 0, l = _nodeSprites.length; i < l; i++) {
				nodeSprite = _nodeSprites[i];
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
		 * Handle node selection drawing manager selected
		 * 
		 * @param event
		 */ 
		private function handleNodeSelectionDrawingManagerSelected(event:NodeSpriteEvent):void
		{
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