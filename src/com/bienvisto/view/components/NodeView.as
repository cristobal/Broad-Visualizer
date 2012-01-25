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
	import flash.geom.Rectangle;
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
		private var lastRect:Rectangle;
		
		/**
		 * @private
		 */ 
		private var lastScale:Number = 1.0;
		
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
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
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
		
		override public function set scale(value:Number):void
		{
			lastScale = scale;
			super.scale = value;
		}
		
		
		/**
		 * @override
		 */ 
		override protected function invalidateScale():void
		{
			super.invalidateScale();
			invalidateScaleCenter(lastScale, scale);
			var manager:NodeDrawingManager;
			for (var i:int = 0, l:int = managers.length; i < l; i++) {
				manager = managers[i];
				manager.scale = scale;
			}
		}
		
		/**
		 * @override
		 */ 
		override public function invalidateSize():void
		{
			super.invalidateSize();
			invalidateCenter();
		}
		
		private function invalidateCenter():void
		{
			// set default center
			if (x == 0 && y == 0) {
				x = (parent.width / 4);
				y = (parent.height / 4);
			}
			// else re-center
			else {
				var dw:Number = lastRect.width  - parent.width;
				var dh:Number = lastRect.height - parent.height;
				
				trace(lastRect.width, parent.width, dw);
				trace(lastRect.height, parent.height, dh);
				
				x -= dw / 4;
				y -= dh / 4;
			}
			
			lastRect = new Rectangle(0, 0, parent.width, parent.height);
		}
		
		/**
		 * Invalidate center
		 * 
		 * @param oldScale
		 * @param newScale
		 */ 
		private function invalidateScaleCenter(oldScale:Number, newScale:Number):void
		{
			// how much we normally see
			var w:Number = parent.width;
			var h:Number = parent.height; 
			
			// diff between how much we used to see now and normally
			var dw:Number = (w * oldScale) - w;
			var dh:Number = (h * oldScale) - h;
			
			// diff between how much we will see now and normally
			var sw:Number = (w * newScale) - w;
			var sh:Number = (h * newScale) - h;
			
			// the diff between both
			var dx:Number = Math.abs(sw - dw);
			var dy:Number = Math.abs(sh - dh);
			
			if (isNaN(dx) || isNaN(dy)) {
				return;
			}
			
			// scale in
			if (newScale > oldScale) {
				x += dx;
				y += dy;
			}
			// scale out
			else {
				x -= dx;
				y -= dy;
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
		
		private function handleAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			invalidateCenter();
		}
		
	}
}