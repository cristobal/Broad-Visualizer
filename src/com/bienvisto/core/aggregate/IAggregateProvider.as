package com.bienvisto.core.aggregate
{
	import com.bienvisto.core.network.node.Node;
	
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