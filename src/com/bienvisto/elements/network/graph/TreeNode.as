package com.bienvisto.elements.network.graph
{
	/**
	 * TreeNode.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class TreeNode
	{
		public function TreeNode(vertex:int, parent:TreeNode = null)
		{
			_vertex = vertex;
			_parent  = parent;
		}
		
		/**
		 * @private
		 */ 
		private var _vertex:int;
		
		/**
		 * @readonly vertex
		 */ 
		public function get vertex():int
		{
			return _vertex;
		}
		
		/**
		 * @private
		 */ 
		private var _parent:TreeNode;
		
		/**
		 * @readonly parent
		 */ 
		public function get parent():TreeNode
		{
			return _parent;
		}
		
	}
}