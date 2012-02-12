package com.broad.core.aggregate
{
	import com.broad.core.network.node.Node;
	
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