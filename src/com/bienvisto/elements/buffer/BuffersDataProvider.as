package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.elements.network.node.Node;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	/**
	 * BuffersDataProvider.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class BuffersDataProvider extends AggregateDataProvider
	{
		public function BuffersDataProvider(buffers:Buffers)
		{
			super("Packets in buffer", 0x0000ff);
			
			this.buffers = buffers;
		}
		
		/**
		 * @private
		 */ 
		private var buffers:Buffers;
		
		/**
		 * @override
		 */ 
		override public function getList(resolution:Number, nodes:Vector.<Node>):ArrayCollection
		{
			trace("resolution:", resolution);
			var tt:int = getTimer();
			var values:Array = [];
			var node:Node;
			var group:int;
			var key:uint;
			var items:Vector.<Buffer>;
			var item:Buffer;
			var map:Dictionary = new Dictionary();
			var data:Object;
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node = nodes[i];
				items = buffers.getItems(node);
				if (items) {
					for (var x:int = 0, n:int = items.length; x < n; x++) {
						item  = items[i];
						group = Math.floor(item.time / resolution);
						// If such group does not exist, we create a new one
						if (values[group] == null)
						{
							values[group] = new Object();
							values[group].hAxis = group*resolution;
							values[group].vAxis = 0;
							values[group].nodeId = node.id;
						}
						
						values[group].vAxis += item.size;
					}
				}
			}
			trace("calculated in: ", getTimer() - tt, "values total of:", values.length);
			return new ArrayCollection(values);
		}
	}
}