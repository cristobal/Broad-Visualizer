package com.bienvisto.view.drawing
{
	import com.bienvisto.view.components.NodeSprite;
	
	public interface INodeDrawingManager
	{
		function update(time:uint, nodeSprites:Vector.<NodeSprite>):void;
	}
}