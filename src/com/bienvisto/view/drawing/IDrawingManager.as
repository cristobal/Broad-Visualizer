package com.bienvisto.view.drawing
{
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.view.VisualizerView;
	import com.bienvisto.view.components.NodeSprite;
	
	import flash.display.Graphics;

	public interface IDrawingManager
	{
		function update(time:uint, nodes:Vector.<NodeSprite>):void;
	}
}