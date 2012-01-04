package com.bienvisto.view.drawing
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
	}
}