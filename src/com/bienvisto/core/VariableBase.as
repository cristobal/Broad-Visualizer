package com.bienvisto.core
{
	import flash.utils.getTimer;

	import mx.collections.ArrayList;

	import com.bienvisto.elements.KeypointBase;

	/**
	 * Class to be extended by all variables to be displayed in the statistics
	 * window.
	 */
	public class VariableBase
	{
	
		/**
		 * Vector containing all the keypoints with the information needed to
		 * represent the variable in a graph
		 */
		protected var keypoints_:Vector.<KeypointBase>;
	
		/**
		 * Constructor of the class. Registers the variable in the visualizer
		 */
		public function VariableBase()
		{
			// Register the variable in the visualizer
			Visualizer.instance.registerVariable(this);
			
			keypoints_ = new Vector.<KeypointBase>();
		}
	
		/**
		 * Name of the variable
		 */
		public function get name():String { return "undefined"; }
		
		
		/**
		 *
		 */ 
		public function get minimumResolution():Number
		{
			throw new Error("minimumResolution getter must be overriden");
			return 0;
		}
		/**
		 *
		 */
		public function get maximumResolution():Number
		{
			throw new Error("maximumResolution getter must be overriden");
			return 0;
		}
		
		/**
		 * Adds a keypoint to this variable. This function should be used to 
		 * add all keypoints needed by this variable
		 */
		public function addKeypoint(keypoint:KeypointBase):void
		{
			keypoints_.push(keypoint);
		}
		
		/**
		 * Returns the values of this variable, grouped by certain resolution.
		 * 
		 * @param resolution The values will be aggregated in groups of this 
		 * size (in milliseconds)
		 * @param nodes Array of node ids. If passed, only the values for these
		 * nodes will be returned
		 */
		public function getValues(resolution:Number,
			nodes:Vector.<int> = null):ArrayList
		{
			var group:int = 1;
			var values:Array = new Array();
			var a:uint = getTimer();
			// Loop through all the keypoints
			for each (var keypoint:KeypointBase in keypoints_)
			{
				// If no selected nodes have been specified or if the node is in
				// the list of selected nodes, we add the keypoint
				if (nodes == null || nodes.length == 0 ||
					nodes.indexOf(keypoint.nodeId) >= 0)
				{
					// Calculate to what group should this keypoint be added
					group = Math.floor(keypoint.milliseconds / resolution);
					
					// If such group does not exist, we create a new one
					if (values[group] == null)
					{
						values[group] = new Object();
						values[group].hAxis = group*resolution;
						values[group].vAxis = 0;
						values[group].nodeId = keypoint.nodeId;
					}
					
					// We aggregate the new keypoint using the method overriden
					// in the derived classes
					values[group].vAxis = aggregateKeypoint(values[group].vAxis,
						values[group].length, keypoint);
				}
			}
			Tools.log(name + " calculated in " + Tools.msToShortString(getTimer()-a));
			
			// We return the calculated values as an ArrayList (the class that
			// can be understood by the charting system)
			return new ArrayList(values);
		}
		
		
		/**
		 * Aggregates a new value to the current calculated value. For instance,
		 * if the variable represented is the bitrate, this function should 
		 * return oldValue + size_of_the_packet_forwarded.
		 * This function must be overriden in all derived classes except when
		 * the getValues is overriden (could be necessary in some cases)
		 *
		 * @param oldValue Value of the appropriate group of the chart before
		 * aggregating the value of the keypoint passed as a parameter
		 * @param groupSize Number of keypoints that have been aggregated to the
		 * befor the current keypoint
		 * @param keypoint Keypoint whose value should be aggregated
		 */
		protected function aggregateKeypoint(oldValue:Number, groupSize:int,
			keypoint:KeypointBase):Number
		{
			throw new Error("aggregateKeypoint has not been overriden in an element class");
			return null;
		}
	}

}
