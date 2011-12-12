package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.network.NodeContainer;
	
	import flash.display.Graphics;

	public interface IDrawingManager
	{
		function update(graphics:Graphics, nodes:NodeContainer):void;
	}
}