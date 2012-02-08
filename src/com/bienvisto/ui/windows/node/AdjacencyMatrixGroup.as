package com.bienvisto.ui.windows.node
{
	import com.bienvisto.core.network.graph.AdjacencyMatrix;
	
	import flash.utils.getTimer;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	import spark.components.Label;
	
	/**
	 * AdjacencyMatrixGroup.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class AdjacencyMatrixGroup extends Group
	{
		/**
		 * Constructor
		 */ 
		public function AdjacencyMatrixGroup()
		{
			super();
			setup();
		}
		
		/**
		 * @private
		 * 	Container for all the header labels
		 */ 
		private var headerLabels:Vector.<Label> = new Vector.<Label>();
		
		/**
		 * @private
		 * 	Container for all the matrix labels
		 */ 
		private var matrixLabels:Vector.<Label> = new Vector.<Label>();
		
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
		
		/**
		 * @readonly adjacencyMatrix
		 */ 
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
			invalidateLabels();
			draw();
		}
		
		/**
		 * Invalidate labels
		 * 	Only append if more labels are needed otherwise hide those not needed.
		 * 	This saves the invalidate loop about 100ms on each invalidating depending 
		 *  on the size of the adjacencymatrix. Thos ms are precious for a good fps.
		 */ 
		private function invalidateLabels():void
		{
			// no matrix and no labels have been assigned yet
			if (!adjacencyMatrix && matrixLabels.length == 0) {
				return;
			}
			
			// no adjacencyMatrix hide all labels
			if (!adjacencyMatrix) {
				for (var i:int = headerLabels.length; i--;){
					headerLabels[i].visible = false;
				}
				for (i = matrixLabels.length; i--;){
					matrixLabels[i].visible = false;
				}
				return;
			}
			
			var vertices:Vector.<int> = adjacencyMatrix.vertices;
			var vertice:int;
			
			var size:int 			  = adjacencyMatrix.size;
			var hsize:int			  = headerLabels.length / 2;
			var lsize:int			  = Math.sqrt(matrixLabels.length);
			
			var labels:Vector.<Label>, label:Label;
			var x:int, y:int;
			
			// append
			if (size > lsize) {
				
				var posX:int = 24;
				var posY:int = 22;
				
				var offsetX:int = 24;
				var offsetY:int = 20;
				
				/* -- Setup header labels -- */
				labels = new Vector.<Label>(size * 2);
				for (x = 0; x < hsize; x++) {
					labels[x]        = headerLabels[x];			// all column headers
					labels[x + size] = headerLabels[x + hsize];	// all row headers 
				}
				
				posX = posX + (offsetX * x);
				posY = posY + (offsetY * x);
				for (;x < size; x++) {
					label = new Label();
					label.width = 24;
					label.setStyle("textAlign", "center");
					label.x = posX;
					posX += offsetX;
					
					addElement(label);
					labels[x] = label; // add column header
					
					
					label = new Label();
					label.width = 20;
					label.setStyle("textAlign", "right");
					label.y = posY;
					posY += offsetY;
					
					addElement(label);
					labels[x + size] = label; // add row header
				}
				headerLabels = labels;		  // store new header labels
				hsize		 = headerLabels.length / 2;
				
				
				/* -- Setup matrix labels --*/
				// create a new labelscontainer 
				labels = new Vector.<Label>(size * size);
				
				// append old into labels into the new labels at the right position
				for (x = 0; x < lsize; x++) {
					for (y = 0; y < lsize; y++) {
						labels[x + (y * size)] = matrixLabels[x + (y * lsize)];
					}
				}
				
				// start expanding 
				// Loop could be more efficient but would have be more loops and logic. 
				// K.I.S.S and just continuing on already created labels
				posY = 24;
				for (y = 0; y < size; y++) {
					posX = 24;
					for (x = 0; x < size; x++) {
						if (labels[x + (y *size)]) {
							posX += offsetX;
							continue; // already created
						}
						label = new Label();
						label.width = 24;
						label.setStyle("fontFamily", "DejaVuSansMono");
						label.setStyle("fontSize", "10px");
						label.setStyle("textAlign", "center");
						label.x = posX;
						label.y = posY;
						// posY += offsetY;
						
						addElement(label);
						labels[x + (y * size)] = label;
						posX += offsetX;
					}
					posY += offsetY;
				}
				
				matrixLabels = labels; // store new matrix labels
				lsize		 = Math.sqrt(matrixLabels.length);
			}
			
			// hide
			else {

				// Hide unecessary header labels
				for (x = size; x < hsize; x++) {
					headerLabels[x].visible = false;
					headerLabels[x + hsize].visible = false;
				}
				
				// Hide unecessary matrix labels
				for (y = size; y < lsize; y++) {
					for (x = 0; x < lsize; x++) {
						matrixLabels[x + (y * lsize)].visible = false;
					}
				}
				for (y = 0; y < lsize; y++) {
					for (x = size; x < lsize; x++) {
						matrixLabels[x + (y * lsize)].visible = false;
					}
				}
				
			}
			
			
			// set header values
			for (x = 0; x < size; x++) {
				vertice = vertices[x];
				headerLabels[x].text 	= String(vertice);
				headerLabels[x].visible = true;
				
				headerLabels[x + hsize].text 	= String(vertice);
				headerLabels[x + hsize].visible = true;
			}
			
			// matrix values
			for (x = 0; x < size; x++) {
				for (y = 0; y < size; y++) {
					 matrixLabels[x + (y * lsize)].text    = adjacencyMatrix.edgeExistsXY(x, y) ? "1" : "0"; 		
					 matrixLabels[x + (y * lsize)].visible = true;
				}
			}
		}
		
		/**
		 * Draw
		 */ 
		private function draw():void
		{
			
			graphics.clear();
			var w:int = 50;
			var h:int = 10;
			if (adjacencyMatrix) {
				var size:int   = adjacencyMatrix.size;
				graphics.lineStyle(2, 0x696969);
				
				// draw x-axis
				graphics.moveTo(0, 18);
				graphics.lineTo((size + 1) * 24, 18);
				
				// draw y-axis
				graphics.moveTo(24, 0);
				graphics.lineTo(24, (size + 1) * 20);
				
				
				graphics.lineStyle(1, 0x696969, 0.25);
				var posY:int = 18 + 20;
				var posX:int = 24 + 24;
				for (var i:int = 1; i < size; i++) {
					// draw x-axis
					graphics.moveTo(0, posY);
					graphics.lineTo((size + 1) * 24, posY);
					posY += 20;
					
					// draw y-axis
					graphics.moveTo(posX, 0);
					graphics.lineTo(posX, (size + 1) * 20);
					posX += 24;
				}
				w = (size + 1) * 24;
				h = posY;
			}
			else {
				graphics.lineStyle(2, 0x696969);
				graphics.moveTo(0, 5);
				graphics.lineTo(25, 5);
				
			}
			
			// we make size clip for elements that are hidden
			width  = w;
			height = h;
			
			// invalidateSize();
		}
	}
}