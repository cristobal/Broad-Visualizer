package com.bienvisto.elements.network.graph
{
	import flash.utils.Dictionary;

	public class GraphSearch
	{
		/**
		 * Find shortest path Dijkstra
		 * 
		 * @param graph
		 * @param from
		 * @param to
		 */
		public static function findShortestPathDijkstra(graph:Graph, from:int, to:int):Vector.<Edge>
		{
			return null;
		}
		
		/**
		 * Find shortest path bfs
		 * 
		 * @param graph
		 * @param from
		 * @param to
		 */ 
		public static function findShortestPathBFS(graph:Graph, from:int, to:int):Vector.<Edge>
		{
			var adjacencyMatrix:AdjacencyMatrix = graph.getAdjacencyMatrix();
			if (!adjacencyMatrix) {
				return null; // 
			}
			
			
			var Q:Vector.<TreeNode> = new Vector.<TreeNode>();
			var Mark:Dictionary = new Dictionary();
			
			var v:TreeNode      = new TreeNode(from);
			var u:TreeNode;
			var w:TreeNode;
			
			var vertices:Vector.<int>;
			var vertex:int;
			var found:Boolean = true;
			
			Q.push(v);
			Mark[v.vertex] = true;
			while (Q.length) {
				u = Q.pop();
				vertices = adjacencyMatrix.getAdjacentVertices(u.vertex);
				for (var i:int = 0, l:int = vertices.length; i < l; i++) {
					vertex = vertices[i];
					if (!(vertex in Mark)) {
						w = new TreeNode(vertex, u);
						Q.push(w);
						Mark[w.vertex] = true;
						if (w.vertex == to) {
							found = true;
							break;
						}
					}
				}
			}
			
			var path:Vector.<Edge>;
			var edge:Edge;
			if (found) {
				path = new Vector.<Edge>();
				
				// walk trough the path
				while(w) {
					v    = w.parent;
					edge = new Edge(v.vertex, w.vertex);
					path.push(edge);
					
					w = v.parent; // swap
				}
				
				path = path.reverse();
			}
			
			
			return path;
		}
	}
}