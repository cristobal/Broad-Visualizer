package com.bienvisto.ui.menus
{
	import com.bienvisto.view.drawing.NodeDrawingManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.events.FlexEvent;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	/**
	 * MenuContainer.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class MenuContainer extends Group
	{
		public function MenuContainer()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
		}
	
		/**
		 * @protected
		 */ 
		protected var optionsAnimation:Animate;
		
		/**
		 * @public
		 */ 
		public var optionsContainer:BorderContainer;
		
		/**
		 * @public
		 */ 
		public var container:BorderContainer; 
		
		/**
		 * @public
		 */ 
		public var browseFileButton:Button;
		
		/**
		 * @public
		 */ 
		public var sequencesButton:Button;
		
		/**
		 * @private
		 */ 
		public var localTopologyButton:Button;
		
		/**
		 * @private
		 */ 
		public var topologyButton:Button;
		
		/**
		 * @public
		 */ 
		public var optionsButton:Button;
		
		
		
		/**
		 * @protected
		 */ 
		protected var managers:Dictionary = new Dictionary();
	
		/**
		 * Init components
		 */ 
		protected function initComponents():void
		{
			if (optionsButton) {
				optionsButton.addEventListener(MouseEvent.CLICK, handleOptionsButtonClick);
				optionsAnimation = new Animate(optionsContainer);
				optionsAnimation.duration = 250;
				optionsAnimation.motionPaths = Vector.<MotionPath>([
					new SimpleMotionPath("y", 0, 30)
				]);
			}
		}
		
		/**
		 * Add toggeable node drawing manager
		 * 
		 * @param manager
		 */ 
		public function addToggeableNodeDrawingManager(manager:NodeDrawingManager):void
		{
			if (optionsContainer) {
				var element:CheckBox = new CheckBox();
				var name:String  = manager.name;
				element.label    = name;
				element.selected = manager.enabled;
				
				optionsContainer.addElement(element);
				element.addEventListener(Event.CHANGE, handleNodeDrawingManagerCheckboxChange, false, 0, true); 
				
				managers[name] = manager;
			}
		}
		
		/**
		 * Handle creation complete
		 * 
		 * @param event
		 */ 
		protected function handleCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			initComponents();
		}
		
		
		/**
		 * Handle options button click
		 * 
		 * @param event
		 */ 
		protected function handleOptionsButtonClick(event:MouseEvent):void
		{
			if (optionsAnimation.isPlaying) {
				return;
			}
			
			if (optionsContainer.y == 0) {
				optionsAnimation.play();
			}
			else {
				optionsAnimation.play(null, true);
			}
		}		
		
		/**
		 * Handle node drawing manager checkbox change
		 * 
		 * @param event 
		 */ 
		protected function handleNodeDrawingManagerCheckboxChange(event:Event):void
		{
			var element:CheckBox = CheckBox(event.target);
			var name:String = element.label;
			// trace("handle change for name", name);
			if (name in managers) {
				var manager:NodeDrawingManager = NodeDrawingManager(managers[name]);
				manager.enabled = element.selected;
			}
		}
		
	}
}