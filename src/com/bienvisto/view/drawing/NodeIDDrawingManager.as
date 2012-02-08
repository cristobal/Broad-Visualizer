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
		 * @override
		 */ 
		override public function reset():void
		{
			textFields = new Dictionary();
		}
		
		/**
		 * @override
		 */ 
		override public function set scale(value:Number):void
		{
			// Scale up the textfield's if the view size is scaled down
			var scale:Number = value;
			if (value < 0.4) {
				scale = 1 + (1 - value) * 4;		
			}
			if (value < 0.7) {
				scale = 1 + (1 - value) * 3;		
			}
			else if (value < 1.0) {
				scale = 1 + (1 - value) * 2;		
			}
			else if (value > 1.0) {
				scale = 1.0;
			}
			
			for each (var textField:TextField in textFields) {
				textField.scaleX = scale;
				textField.scaleY = scale;
			}
		}
		
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
			if (enabled) {
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
				
			}
		}
	}
}