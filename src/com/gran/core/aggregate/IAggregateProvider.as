package com.gran.core.aggregate
{
	import com.gran.core.network.node.Node;
	
	/**
	 * IAggregateProvider.as
	 * 
	 * @author Cristobal DAbed
	 */ 
	public interface IAggregateProvider
	{
		function getItems(node:Node):Vector.<Aggregate>;
	}
}