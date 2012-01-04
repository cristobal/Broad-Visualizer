package com.bienvisto.view.drawing
{
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	public final class NodeIDDrawingManager extends NodeDrawingManager
	{
		public function NodeIDDrawingManager()
		{
			super("Node ID");
			var fonts:Array = Font.enumerateFonts();
			for each(var font:Font in fonts) {
				trace("embedded font:", font.fontName);
			}
		}
		
		/**
		 * @private
		 */ 
		private var textFields:Dictionary = new Dictionary();
		
		private var textFormat:TextFormat = new TextFormat("DejaVuSansDF3", 13, 0x545454, true);
		
		/**
		 * @private
		 */ 
		private var lastTime:uint = 0;
		
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

						trace("Adding textField with id:", textField.text);
						nodeSprite.addChild(textField);
						
						textFields[id] = textField;
					}
				}
				
				lastTime = time;
			}
		}
	}
}