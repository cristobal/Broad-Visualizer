package com.bienvisto.view.drawing
{
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	/**
	 * NodeIDDrawingManager.as
	 * 	Responsible for drawing the textFields
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeIDDrawingManager extends NodeDrawingManager
	{
		public function NodeIDDrawingManager()
		{
			super("Node ID");
		}
		
		
		/**
		 * @private
		 */ 
		private var textFields:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var textFormat:TextFormat = new TextFormat("DejaVuSansDF3", 13, 0x545454, true);
		
		/**
		 * @private
		 */ 
		private var lastTime:uint = 0;
		
		
		/**
		 * @override
		 */ 
		override protected function invalidate():void
		{
			for each (var textField:TextField in textFields) {
				textField.visible = enabled;	
			}
			
			super.invalidate();
		}
		
		/**
		 * @override
		 */ 
		override public function update(time:uint, nodeSprites:Vector.<NodeSprite>):void
		{
			if ((lastTime != time) && enabled) {
				var id:int, nodeSprite:NodeSprite, textField:TextField;
				
				for (var i:int = 0, l:int = nodeSprites.length; i < l; i++) {
					nodeSprite = nodeSprites[i];
					id = nodeSprite.node.id;
					if (!(id in textFields)) {
						textField = new TextField();
						textField.x = nodeSprite.cx / 6;
						textField.y = nodeSprite.cy * 2;
						textField.embedFonts = true;
						textField.text = "#" + String(id);
						textField.setTextFormat(textFormat);
						
						nodeSprite.addChild(textField);
						
						textFields[id] = textField;
					}
				}
				
				lastTime = time;
			}
		}
	}
}