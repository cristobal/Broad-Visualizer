package com.bienvisto.view.overlays
{
	import com.bienvisto.core.network.node.NodeContainer;
	
	import mx.core.FlexSprite;
	import com.bienvisto.view.components.NodeSprite;
	
	public class OverlayView extends FlexSprite
	{
		public function OverlayView()
		{
			super();
		}
		
		public function update(nodes:Vector.<NodeSprite>):void
		{
			throw new Error("Subclass must override this function!");
		}
	}
}