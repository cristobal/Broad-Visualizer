package com.bienvisto.view
{
	import com.bienvisto.core.network.node.Node;
	import com.bienvisto.core.network.node.NodeContainer;
	import com.bienvisto.view.components.MiniMapView;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.ViewComponent;
	import com.bienvisto.view.drawing.IDrawingManager;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.effects.Tween;
	import mx.events.SandboxMouseEvent;
	
	import spark.components.Group;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.EaseInOutBase;
	
	/**
	 * VisualizerView.as
	 * 	This class contains as set of view components and tells them to update(refresh) 
	 *  their content when an update is issued to this view.
	 * 
	 *  Its an abstract representation for an class that contains all the views that simulate one or
	 *  more properties from the simulation seen as a whole visualization view.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class VisualizerView extends Group
	{	
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		/**
		 * VisualizerView
		 */ 
		public function VisualizerView()
		{
			super();
			setup();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  viewComponents
		//---------------------------------- 
		/**
		 * @private
		 * 	Reference to all the view components that are added to this view
		 */ 
		private var _viewComponents:Vector.<ViewComponent> = new Vector.<ViewComponent>();
		
		/**
		 * @readonly viewComponents
		 */ 
		public function get viewComponents():Vector.<ViewComponent>
		{
			return  _viewComponents;
		}
		
		//----------------------------------
		//  time
		//---------------------------------- 
		/**
		 * @private
		 * 	The current time in this view
		 */ 
		private var _time:uint = 0;
		
		/**
		 * @readwrite time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		public function setTime(time:uint):void
		{
			_time = time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{	
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		
		/**
		 * Add a view component
		 * 
		 * @param item
		 */ 
		public function addViewComponent(item:ViewComponent):void
		{
			_viewComponents.push(item);
			addElement(item);
		}
		
		
		/**
		 * Remove view component
		 * 
		 * @param item
		 */ 
		private function removeViewComponent(item:ViewComponent):void
		{
			var view:ViewComponent;
			for (var i:int = _viewComponents.length; i--;) {
				item = _viewComponents[i];
				if (view === item) {
					_viewComponents.splice(i, 1);
					removeElement(view);
				}
			}
		}
		
		/**
		 * Reset
		 */ 
		public function reset():void
		{
			var viewComponent:ViewComponent;
			for (var i:int = 0, l:int = _viewComponents.length; i < l; i++) {
				viewComponent = _viewComponents[i];
				viewComponent.reset();
			}
			setTime(0);
		}
		
		/**
		 * Update
		 * 	Tell the view to update(refresh) all its view components
		 */ 
		private function update():void
		{	
			var tt:int = getTimer();
			var viewComponent:ViewComponent;
			for (var i:int = 0, l:int = _viewComponents.length; i < l; i++) {
				viewComponent = _viewComponents[i];
				viewComponent.update(time);
			}
			if (s != time) {
				s = time;
				sum += (getTimer() - tt);
				total++;
				if (total % 10 == 0) {
					trace("Avg update time:", String(sum / total), "ms");
					total = 0;
					sum   = 0;
				}
				
			}
		}
		
		private var total:Number = 0;
		private var sum:Number = 0;
		private var s:int      = -1;
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			width  = parent.width;
			height = parent.height;
			
			var viewComponent:ViewComponent;
			for (var i:int = 0, l:int = _viewComponents.length; i < l; i++) {
				viewComponent = _viewComponents[i];
				viewComponent.invalidateSize();
			}
		}		
		
		
		//--------------------------------------------------------------------------
		//
		//  Loader view
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var loaderView:ViewComponent;
		
		/**
		 * @readwrite loaderViewVisible
		 */ 
		public function get loaderViewVisible():Boolean
		{
			var value:Boolean;
			
			if (loaderView) {
				value = loaderView.visible;
			}
			
			return value;
		}
		
		public function set loaderViewVisible(value:Boolean):void
		{
			if (loaderView) {
				loaderView.visible = value;
				invalidateLoaderView();
			}
		}
		
		/**
		 * Set loader view
		 * 
		 * @param view
		 */ 
		public function setLoaderView(view:ViewComponent):void
		{
			loaderView = view;
			loaderView.visible = false; // initialize as hidden
		}
		
		/**
		 * Setup loader view
		 */ 
		private function invalidateLoaderView():void
		{
			addElementAt(loaderView, numElements - 1);
			if (parent) {
				loaderView.setSize(parent.width, parent.height);
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Mini map view
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var miniMapView:ViewComponent;
		
		/**
		 * Set loader view
		 * 
		 * @param view
		 */ 
		public function setMiniMapView(view:ViewComponent):void
		{
			miniMapView = view;
			addEventListener(MouseEvent.CLICK, handleMiniMapViewMouseClick);
		}
		
		/**
		 * Handle mouse click
		 * 
		 * @param event
		 */ 
		private function handleMiniMapViewMouseClick(event:MouseEvent):void
		{
			if (miniMapView && !miniMapView.visible) {
				return;
			}
			
			
			
			var sx:Number  = event.stageX;
			var sy:Number  = event.stageY;
			
			var w:Number   = miniMapView.width;
			var h:Number   = miniMapView.height;
			
			var dx:Number  = miniMapView.x;
			var dx2:Number = dx + w;
			var dy:Number  = miniMapView.y;
			var dy2:Number = dy + h;
			if (sx > dx && sx < dx2 && sy > dy && sy < dy2) {
				var rect:Rectangle = MiniMapView(miniMapView).displacedRect;
				if (rect && rect.width > 0 && rect.height > 0) {
					
					// Get rect, width for displaced rect
					var aw:Number = rect.width;
					var ah:Number = rect.height;
					
					// Get local point on min map view
					var lx:Number = (sx - dx) * (aw / w);
					var ly:Number = (sy - dy) * (ah / h);
					
					// Normalize to point on the view
					var nx:Number = lx * aw;
					var ny:Number = ly * ah;
					
					// Get center point
					var cx:Number = parent.width / 2;
					var cy:Number = parent.height / 2;
					
					// Get Point(dx,dy) such that Point(lx,y) is centered at the center Point(cx, cy) of the view. 
					dx = cx - lx;
					dy = cy - ly;
					
					var animate:Animate = new Animate(draggableView);
					var easer:EaseInOutBase = new EaseInOutBase();
					animate.easer = easer;
				
					animate.motionPaths = Vector.<MotionPath>([
						new SimpleMotionPath("x", draggableView.x, dx),
						new SimpleMotionPath("y", draggableView.y, dy)
					]);
					
					animate.play();
				}
			}
			
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Draggable view
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	Flag that tells wether the draggable state has been enabled
		 */ 
		private var draggable:Boolean = false;
		
		/**
		 * @private
		 * 	Flag which tells wether we are currently dragging or not
		 */ 
		private var isDragging:Boolean = false;
		
		/**
		 * @private
		 * 	Used to store the last point from which the drag distance is calculated
		 */ 
		private var lastDragPoint:Point;

		/**
		 * @private 
		 * 	Timer used to delay time before is dragging state is enabled, 
		 *   this ensures that user clicks around the view are interpreted as clicks and not dragging
		 */ 
		private var dragTimer:Timer;
		
		/**
		 * @private
		 * 	The drag timer delay before enabling as is dragging
		 */ 
		private var dragTimerDelay:Number = 120;
		
		/**
		 * @private
		 * 	The view which is to be dragged
		 */ 
		private var draggableView:ViewComponent;
		
		/**
		 * Set draggable view
		 * 
		 * @param view
		 */ 
		public function setDraggableView(view:ViewComponent):void
		{
			draggableView = view;	
			setupDraggableView();
		}
		
		/**
		 * Setup draggable view
		 */ 
		private function setupDraggableView():void
		{
			dragTimer = new Timer(dragTimerDelay, 1);
			dragTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleDragTimerComplete);
			addEventListener(MouseEvent.MOUSE_DOWN, handleDragMouseDown);
		}
		
		/**
		 * Handle drag timer complete
		 */ 
		private function handleDragTimerComplete(event:TimerEvent):void
		{
			if (draggable) {
				Mouse.cursor = MouseCursor.HAND;
				isDragging = true;
			}
		}
		
		/**
		 * Handle mouse down
		 * 
		 * @param event
		 */ 
		private function handleDragMouseDown(event:MouseEvent):void
		{
			if (!draggable) {
				lastDragPoint = new Point(event.stageX, event.stageY);
				draggable = true;
				dragTimer.start();
				
				var root:DisplayObject = systemManager.getSandboxRoot();
				root.addEventListener(MouseEvent.MOUSE_MOVE, handleDragMouseMove);
				root.addEventListener(MouseEvent.MOUSE_UP, handleDragMouseUp);
				root.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleDragMouseUp);
			}
		}
		
		/**
		 * Handle mouse up
		 * 
		 * @param event
		 */ 
		private function handleDragMouseUp(event:MouseEvent):void
		{
			if (dragTimer.running) {
				dragTimer.stop();
			}
			
			Mouse.cursor = MouseCursor.AUTO;
			draggable  = false;	
			isDragging = false;
			
			var root:DisplayObject= systemManager.getSandboxRoot();
			root.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMouseMove);
			root.removeEventListener(MouseEvent.MOUSE_UP, handleDragMouseUp);
			root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleDragMouseUp);
		}
		
		/**
		 * Handle mouse move
		 * 
		 * @param event
		 */ 
		private function handleDragMouseMove(event:MouseEvent):void
		{
			if (!draggable) {
				return;
			}
			
			var stageY:Number = event.stageY;
			var stageX:Number = event.stageX;
			
			if (isDragging) {
				var dx:Number = stageX - lastDragPoint.x;
				var dy:Number = stageY - lastDragPoint.y;
				
				draggableView.x += dx;
				draggableView.y += dy;
			}
			
			// store current position as las position.
			lastDragPoint = new Point(stageX, stageY);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Events
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Handle enter frame
		 * 
		 * @param event
		 */ 
		private function handleEnterFrame(event:Event):void
		{
			update();
		}
		
		/**
		 * Handle resize
		 */ 
		private function handleResize(event:Event):void
		{
			invalidate();	
			invalidateLoaderView();
		}
		
		/**
		 * Handle added to stage
		 * 
		 * @param event
		 */ 
		private function handleAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			parent.addEventListener(Event.RESIZE, handleResize);
			invalidate();
		}
		
	}
}