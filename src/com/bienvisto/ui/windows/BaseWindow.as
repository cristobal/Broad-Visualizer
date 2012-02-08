package com.bienvisto.ui.windows
{	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.MoveEvent;
	import mx.events.SandboxMouseEvent;
	import mx.graphics.SolidColor;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.TitleWindow;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Path;
	import spark.skins.spark.TitleWindowSkin;
	
	/**
	 * BaseWindow.as
	 * 	The base window class for all the floating windows in the application.
	 *  Manages properties such as moving and constraining the movement area.
	 *  In addition to the resizing of the windows.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class BaseWindow extends TitleWindow
	{
		
		//--------------------------------------------------------------------------
		//
		// Class Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static var offsetTop:Number = 30;
		
		/**
		 * @private
		 */ 
		private static var offsetBottom:Number = 20 + offsetTop;
		
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */ 
		public function BaseWindow()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			addEventListener(CloseEvent.CLOSE, handleClose);	
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @protected
		 */ 
		protected var positionFixed:Boolean = false;
		
		/**
		 * @protected
		 */ 
		protected var resized:Boolean = false;
		
		/**
		 * @protected
		 */ 
		protected var resizeHandle:Group;
		
		/**
		 * @protected
		 */
		protected var resizeListener:Boolean = false;
		
		/**
		 * @protected
		 */ 
		protected var resizeRectangle:Rectangle;
		
		/**
		 * @protected
		 */ 
		protected var parentRectangle:Rectangle;
		
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------------
		
		//----------------------------------
		//  defaultAsFloatingWindow
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _defaultAsFloatingWindow:Boolean = true;
		
		/**
		 * @readonly get registeredAsPopUp
		 * 	Wether this component has been registered as a floating window
		 */ 
		public function get defaultAsFloatingWindow():Boolean
		{
			return _defaultAsFloatingWindow;
		}
		
		public function set defaultAsFloatingWindow(value:Boolean):void
		{
			_defaultAsFloatingWindow = value;
		}
		
		//----------------------------------
		//  registeredAsFloatingWindow
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _registeredAsFloatingWindow:Boolean = false;
		
		/**
		 * @readonly get registeredAsPopUp
		 * 	Wether this component has been registered as a popup element
		 */ 
		public function get registeredAsFloatingWindow():Boolean
		{
			return _registeredAsFloatingWindow;
		}
		
		//----------------------------------
		//  resizable
		//---------------------------------- 
		
		/**
		 * @private
		 */ 
		private var _resizable:Boolean = true;
		
		/**
		 * @readwrite get _resizable
		 * 	Wether this component has been registered as a popup element
		 */ 
		public function get resizable():Boolean
		{
			return _resizable;
		}
		
		public function set resizable(value:Boolean):void
		{
			if (resizable != value) {
				_resizable = value;
				invalidateResizable();
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Setup
		 */ 
		protected function setup():void
		{
			// set the style
			var titleWindowSkin:TitleWindowSkin = TitleWindowSkin(skin); 
			titleWindowSkin.dropShadow.blurX = 10;
			titleWindowSkin.dropShadow.blurY = 5;
			titleWindowSkin.dropShadow.distance = 7;
			titleWindowSkin.titleDisplay.minHeight = 28;
			// HorizontalLayout(titleWindowSkin.controlBarGroup.layout).paddingBottom = 0;
			// HorizontalLayout(titleWindowSkin.controlBarGroup.layout).gap = 0;
			
			resizeHandle = new Group();
			resizeHandle.width  = 15;
			resizeHandle.height = 15;
			resizeHandle.setStyle("right", 0);
			resizeHandle.setStyle("bottom", 0);
			
			var path:Path = new Path();
			path.data = "M 2 13 L 13 2 L 13 13 L 2 13";
			path.fill = new SolidColor(0x333333);
			resizeHandle.addElement(path);
			
			contentGroup.addElement(resizeHandle);	
			resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, handleResizeMouseDown);
			invalidateResizable();
			
			
			minWidth  = width;
			minHeight = height; 
			
			if (defaultAsFloatingWindow) {
				registerAsFloatingWindow();
			}
		}
		
		/**
		 * Toggle
		 */ 
		public function toggle():void
		{
			visible = !visible;
		}
		
		/**
		 * On close
		 */ 
		protected function onClose():void
		{
			visible = false;
		}
		
		/**
		 * Register as popup
		 */ 
		protected function registerAsFloatingWindow():void
		{
			try {
				TitleWindowSkin(skin).topGroup.addEventListener(MouseEvent.MOUSE_DOWN, handleTopGroupMouseDown);
				addEventListener(MoveEvent.MOVE, handleMoveEvent);
				
				// PopUpManager.addPopUp(this, parent);
			}
			catch(error:Error) {
				// fail silently
			}
			_registeredAsFloatingWindow = true;
		}
		
		/**
		 * Unregister as popup
		 */ 
		protected function unregisterAsPopup():void
		{
			if (_registeredAsFloatingWindow) {
				try {
					removeEventListener(MoveEvent.MOVE, handleMoveEvent);
					// PopUpManager.removePopUp(this);	
				}
				catch (error:Error) {
					// fail silently
				}
			}
		}
		
		/**
		 * Invalidate resizable
		 */ 
		protected function invalidateResizable():void
		{
			if (resizeHandle) {
				resizeHandle.visible = resizable;
			}
		}
		
		/**
		 * Set initial position
		 * 
		 * @param top
		 * @param right
		 * @param bottom
		 * @param left
		 */ 
		public function setInitialPosition(top:*, right:*, bottom:*, left:*):void
		{
			
			setStyle("top", top);
			setStyle("right", right);
			setStyle("bottom", bottom);
			setStyle("left", left);

			positionFixed = true;
			invalidateResizeListener();
		}
		
		/**
		 * Invalidate position fixed
		 */ 
		public function invalidatePositionFixed():void 
		{
			setStyle("top", "");
			setStyle("right", "");
			setStyle("bottom", "");
			setStyle("left", "");
			
			positionFixed = false;
			invalidateResizeListener();
		}
		
		/**
		 * Invalidate resize listener
		 */ 
		protected function invalidateResizeListener():void
		{
			if (!stage) {
				return;
			}
			
			if (positionFixed && !resizeListener) {
				stage.addEventListener(Event.RESIZE, handleStageResize, true);
				resizeListener = false;
			}
			else if (!positionFixed && resizeListener) {
				stage.removeEventListener(Event.RESIZE, handleStageResize, true);
				resizeListener = false;
			}
		}
		
		/**
		 * On resize changed
		 */ 
		protected function onResizeChange():void
		{
			
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Events
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		protected function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			setup();
		}
		
		/**
		 * Handle removed from stage
		 * 
		 * @param event
		 */ 
		protected function handleRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleRemovedFromStage);
			unregisterAsPopup();	
		}
		
		/**
		 * Handle stage resize
		 * 
		 * @param event
		 */ 
		protected function handleStageResize(event:Event):void
		{
			parentRectangle = new Rectangle(0, 0, parent.width, parent.height);
			resized 		= true;
		}
		
		/**
		 * Handle close
		 * 
		 * @param event
		 */ 
		protected function handleClose(event:CloseEvent):void
		{
			onClose();
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Drag/Move Event handling
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var lastMovePoint:Point;
		
		/**
		 * Handle move event
		 * 
		 * @param event
		 */ 
		protected function handleMoveEvent(event:MoveEvent):void
		{
			if (x < 0) {
				x = 0;
			}
			else if(x > (parent.width - width)) {
				x = parent.width - width;
			}
			
			var parentHeight:Number = parent.height;
			if (y < offsetTop) {
				y = offsetTop;
			}
			else if (y > parent.height - (height + offsetBottom)) {
				y = parent.height - (height + offsetBottom);
				parent.height = parentHeight; // restore parent height
			}
			
			if (!positionFixed || !parent || !parentRectangle) {
				return;
			}
			
			if ((parent.width == parentRectangle.width)  && (parent.height == parentRectangle.height) && !resized) {
				invalidatePositionFixed();
			}
			else if (resized) {
				resized = false;
			}
			
		}
		
		/**
		 * Handle top group mouse down
		 * 
		 * @param event
		 */ 
		protected function handleTopGroupMouseDown(event:MouseEvent):void
		{
			var root:DisplayObject = systemManager.getSandboxRoot();
			root.addEventListener(MouseEvent.MOUSE_MOVE, handleTopGroupMouseMove);
			root.addEventListener(MouseEvent.MOUSE_UP, handleTopGroupMouseUp);
			root.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleTopGroupMouseUp);
			
			lastMovePoint = new Point(event.stageX, event.stageY);
		}
		
		/**
		 * Handle top group mouse down
		 * 
		 * @param event
		 */
		protected function handleTopGroupMouseMove(event:MouseEvent):void
		{
			invalidatePositionFixed();
			
			var stageX:Number = event.stageX;
			var stageY:Number = event.stageY;
			
			var dx:Number = stageX - lastMovePoint.x;
			var dy:Number = stageY - lastMovePoint.y;
			
			x += dx;
			y += dy;
			
			lastMovePoint = new Point(stageX, stageY);
		}
		
		/**
		 * Handle top group mouse down
		 * 
		 * @param event
		 */
		protected function handleTopGroupMouseUp(event:MouseEvent):void
		{
			var root:DisplayObject = systemManager.getSandboxRoot();
			root.removeEventListener(MouseEvent.MOUSE_MOVE, handleTopGroupMouseMove);
			root.removeEventListener(MouseEvent.MOUSE_UP, handleTopGroupMouseUp);
			root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleTopGroupMouseUp);
		}
		
		//--------------------------------------------------------------------------
		//
		// Resize event handling
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Handle resize mouse down
		 * 
		 * @param event
		 */ 
		protected function handleResizeMouseDown(event:MouseEvent):void
		{
			if (!resizeRectangle) {
				resizeRectangle = new Rectangle(event.stageX, event.stageY, width, height);
				var root:DisplayObject = systemManager.getSandboxRoot();
				
				
				root.addEventListener(MouseEvent.MOUSE_MOVE, handleResizeMouseMove);
				root.addEventListener(MouseEvent.MOUSE_UP, handleResizeMouseUp);
				root.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleResizeMouseUp);
			}
		}
		
		/**
		 * Handle resize mouse move
		 * 
		 * @param event
		 */ 
		protected function handleResizeMouseMove(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			
			if (!resizeRectangle) {
				return;
			}
			
			var w:Number = resizeRectangle.width + (event.stageX - resizeRectangle.x);
			var h:Number = resizeRectangle.height + (event.stageY - resizeRectangle.y);
			if (y + h > parent.height - offsetBottom) {
				h = (parent.height - offsetBottom) - y;
			}
			
			var parentHeight:Number = parent.height;
			
			width  = w < minWidth ? minWidth : w;
			height = h < minHeight ? minHeight : h;
			
			parent.height = parentHeight; // restore parent height
			event.updateAfterEvent();
			
			onResizeChange();
			if (positionFixed) {
				invalidatePositionFixed();
			}
		}
		
		/**
		 * Handle resize mouse up
		 * 
		 * @param event
		 */ 
		protected function handleResizeMouseUp(event:Event):void
		{
			resizeRectangle = null;
			
			var root:DisplayObject = systemManager.getSandboxRoot();
			
			root.removeEventListener(MouseEvent.MOUSE_MOVE, handleResizeMouseMove);
			root.removeEventListener(MouseEvent.MOUSE_UP, handleResizeMouseUp);
			root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleResizeMouseUp);		
		}
		

	}
}