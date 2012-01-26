package com.bienvisto.elements.network.graph
{
	import flash.utils.Dictionary;

	/**
	 * AdjacencyMatrix.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class AdjacencyMatrix
	{
		public function AdjacencyMatrix(vertices:Vector.<int>, keys:Dictionary, matrix:Vector.<int>)
		{
			_vertices = vertices;
			_keys     = keys;
			_matrix   = matrix;
		}
		
		/**
		 * @private
		 */  
		private var _vertices:Vector.<int>;
		
		/**
		 * @readonly vertices
		 */ 
		public function get vertices():Vector.<int>
		{
			return _vertices;
		}
		
		/**
		 * @private
		 */  
		private var _keys:Dictionary;
		
		/**
		 * @readonly keys
		 */ 
		public function get keys():Dictionary
		{
			return _keys;
		}
		
		/**
		 * @private
		 */ 
		private var _matrix:Vector.<int>;
		
		/**
		 * @readonly matrix
		 */ 
		public function get matrix():Vector.<int>
		{
			return _matrix;
		}
		
		/**
		 * @readonly size
		 */ 
		public function get size():int 
		{
			return vertices.length;
		}
		
		/**
		 * Edge exists
		 * 
		 * @param from
		 * @param to
		 */ 
		public function edgeExists(from:int, to:int):Boolean
		{
			var x:int = keys[from];
			var y:int = keys[to];
			
			return edgeExistsXY(x, y);
		}
		
		/**
		 * Edge exists
		 * 
		 * @param from
		 * @param to
		 */ 
		public function edgeExistsXY(x:int, y:int):Boolean
		{
			return matrix[x + (y * size)];
		}
		
	}
}