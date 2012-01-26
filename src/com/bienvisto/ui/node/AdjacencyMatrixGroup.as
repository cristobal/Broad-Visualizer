package com.bienvisto.ui.node
{
	import com.bienvisto.elements.network.graph.AdjacencyMatrix;
	
	import spark.components.Group;
	import spark.components.Label;
	
	public final class AdjacencyMatrixGroup extends Group
	{
		public function AdjacencyMatrixGroup()
		{
			super();
			setup();
		}
		
		/**
		 * @private
		 */ 
		private var _adjacencyMatrix:AdjacencyMatrix;
		
		/**
		 * @readwrite adjacencyMatrix
		 */ 
		public function set adjacencyMatrix(value:AdjacencyMatrix):void
		{
			if (_adjacencyMatrix != value) {
				_adjacencyMatrix = value;
				invalidate();
			}
		}
		
		public function get adjacencyMatrix():AdjacencyMatrix
		{
			return _adjacencyMatrix;
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			invalidate();
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			draw();
		}
		
		/**
		 * Draw
		 */ 
		private function draw():void
		{
			removeAllElements();
			graphics.clear();
			if (adjacencyMatrix) {
				
				var vertices:Vector.<int> = adjacencyMatrix.vertices;
				// trace("vertices:", vertices);
				var size:int              = adjacencyMatrix.size;
				var vertice:int;
				var label:Label;
				var posX:int = 24;
				var posY:int = 22;
				
				var offsetX:int = 24;
				var offsetY:int = 20;
				for (var i:int = 0; i < size; i++) {
					vertice = vertices[i];
					label   = new Label();
					label.text  = String(vertice);
					label.width = 24;
					label.setStyle("textAlign", "center");
					addElement(label);
					
					label.x = posX;
					posX += offsetX;
					
					vertice = vertices[i];
					label   = new Label();
					label.text = String(vertice);
				
					label.width = 20;
					label.setStyle("textAlign", "right");
					addElement(label);
					
					label.y = posY;
					label.x = 0;
					posY += offsetY;
				}
				
				
				graphics.lineStyle(2, 0x696969);
				
				// draw x-axis
				graphics.moveTo(0, 18);
				graphics.lineTo((size + 1) * 24, 18);
				
				// draw y-axis
				graphics.moveTo(24, 0);
				graphics.lineTo(24, (size + 1) * 20);
				
				
				graphics.lineStyle(1, 0x696969, 0.25);
				posY = 18 + 20;
				posX = 24 + 24;
				for (i = 1; i < size; i++) {
					// draw x-axis
					graphics.moveTo(0, posY);
					graphics.lineTo((size + 1) * 24, posY);
					posY += 20;
					
					// draw y-axis
					graphics.moveTo(posX, 0);
					graphics.lineTo(posX, (size + 1) * 20);
					posX += 24;
				}
				
				var edgeExists:Boolean;
				
				posX = 24;
				for (var x:int = 0; x < size; x++) {
					posY = 24;
					for (var y:int = 0; y < size; y++) {
						edgeExists = adjacencyMatrix.edgeExistsXY(x, y);
						
						label = new Label();
						label.text = edgeExists ? "1" : "0";
						label.width = 24;
						
						label.setStyle("fontFamily", "DejaVuSansMono");
						label.setStyle("fontSize", "10px");
						label.setStyle("textAlign", "center");
						addElement(label);
						
						label.x = posX;
						label.y = posY;
						
						posY += 20;
					}
					
					posX += 24;
				}
				
			}
			else {
				graphics.lineStyle(2, 0x696969);
				graphics.moveTo(0, 5);
				graphics.lineTo(25, 5);
			}
		}
	}
}