package com.bienvisto.elements.network.graph
{
	import com.bienvisto.elements.routing.RoutingTableEntry;
	
	import flash.utils.Dictionary;
	
	import spark.primitives.Path;
	
	// TODO: Implement FSP
	/**
	 * Graph.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class Graph
	{
		public function Graph()
		{
		}
		
		/**
		 * @private
		 */ 
		private var edges:Vector.<Edge> = new Vector.<Edge>();
		
		/**
		 * @private
		 */ 
		private var _adjacencyMatrix:AdjacencyMatrix;
		
		/**
		 * Add edge
		 * 
		 * @param from 
		 * @param to
		 */ 
		public function addEdge(from:int, to:int):void
		{
			var add:Boolean = true;
			var edge:Edge;
			for (var i:int = edges.length; i--;) {
				edge = edges[i];
				if ((edge.from == from) && (edge.to == to)) {
					add = false; // edge already present
					break;	
				}
			}
			
			// only add if not present
			if (add) {
				edge = new Edge(from,to);
				edges.push(edge);
				_adjacencyMatrix = null;
			}
		}
		
		/**
		 * Remove edge
		 * 
		 * @param from
		 * @param to
		 */ 
		public function removeEdge(from:int, to:int):void
		{
			var removed:Boolean = false;
			var edge:Edge;
			
			for (var i:int = edges.length; i--;) {
				edge = edges[i];
				if ((edge.from == from) && (edge.to == to)) {
					edges.splice(i, 1); // remove the edge
					removed = true;
					edge    = null;
					break;	
				}
			}
			
			if (removed) {
				_adjacencyMatrix = null;
			}
		}
		
		/**
		 * Get adjancy matrix
		 * 
		 * @return 
		 */ 
		public function getAdjacencyMatrix():AdjacencyMatrix
		{
			if (_adjacencyMatrix) {
				return _adjacencyMatrix;
			}
			
			if (edges.length == 0) {
				return null;
			}
			
			var vertices:Vector.<int> = getVertices();
			var size:int 			  = vertices.length;
			var matrix:Vector.<int>   = new Vector.<int>(size * size, true);
			var keys:Dictionary		  = new Dictionary();
			
			var vertice:int;
			for (var key:int = 0; key < size; key++) {
				vertice = vertices[key];
				keys[vertice] = key;
			}
			
			
			var from:int, to:int;
			
			var edge:Edge;
			var x:int, y:int;
			for (var i:int = 0, l:int = edges.length; i < l; i++) {
				edge = edges[i];
				
				from = edge.from;
				to   = edge.to;
				
				x    = keys[to];
				y    = keys[from];
				
				matrix[x + (y * size)] = 1;
			}
			
			_adjacencyMatrix = new AdjacencyMatrix(vertices, keys, matrix);
		
			
			return _adjacencyMatrix;
		}
		
		
		/**
		 * Get vertices
		 */ 
		private function getVertices():Vector.<int>
		{
			var values:Array   = [];
			var lut:Dictionary = new Dictionary();
			
			var edge:Edge;
			var from:int, to:int;
			for (var i:int = edges.length; i--;) {
				edge = edges[i];
				from = edge.from;
				to   = edge.to;
				
				if (!(from in lut)) {
					values.push(from);
					lut[from] = true;
				}
				
				if (!(to in lut)) {
					values.push(to);
					lut[to] = true;
				}
			}
			
			values.sort(Array.NUMERIC); // sort numeric ASC
			return Vector.<int>(values);
		}
		
		/**
		 * Get adjacent vertices
		 * 
		 * @param from
		 */ 
		public function getAdjacentVertices(from:int):Vector.<int>
		{
			var vertices:Vector.<int>;
			var adjacencyMatrix:AdjacencyMatrix = getAdjacencyMatrix();
			
			if (adjacencyMatrix) {
				vertices = adjacencyMatrix.getAdjacentVertices(from);
			}
			else {
				vertices = new Vector.<int>();
			}
			
			return vertices;
		}

		/**
		 * Find shortest path - Dijkstra
		 * 
		 * @param from
		 * @param to
		 */ 
		public function findShortestPathDijkstra(from:int, to:int):Vector.<Edge>
		{
			return GraphSearch.findShortestPathDijkstra(this, from, to);
		}
		
		/**
		 * Find shortest path - Breadth first search
		 * 
		 * @param from
		 * @param to
		 */ 
		public function findShortestPathBFS(from:int, to:int):Vector.<Edge>
		{
			return GraphSearch.findShortestPathBFS(this, from, to);
		}
		
		/**
		 * To string
		 */ 
		public function toString():String
		{
			var args:Array = [];
			for (var i:int = 0, l:int = edges.length; i < l; i++) {
				args.push(
					edges[i].toString()
				);
			}
			
			return args.join("\n");
		}
	}
	
}