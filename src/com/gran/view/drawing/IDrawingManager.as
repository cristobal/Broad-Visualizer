package com.gran.view.drawing
{
	/**
	 * IDrawingManager.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public interface IDrawingManager
	{
		function get name():String;
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
		function set scale(value:Number):void;
	}
}