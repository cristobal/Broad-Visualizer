package com.bienvisto.view.drawing
{
	import com.bienvisto.view.components.NodeSprite;
	
	public interface INodeDrawingManager
	{
		function update(time:uint, nodeSprites:Vector.<NodeSprite>):void;
		function get name():String;
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
	}
}