package com.bienvisto.view.overlays
{
	import com.bienvisto.elements.network.NodeContainer;
	
	import mx.core.FlexSprite;
	import com.bienvisto.view.components.CanvasNode;
	
	public class OverlayView extends FlexSprite
	{
		public function OverlayView()
		{
			super();
		}
		
		public function update(nodes:Vector.<CanvasNode>):void
		{
			throw new Error("Subclass must override this function!");
		}
	}
}