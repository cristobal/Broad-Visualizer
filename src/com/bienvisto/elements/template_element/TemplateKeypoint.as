package com.bienvisto.elements.template_element
{
	import com.bienvisto.elements.KeypointBase;


	/**
	 * Template for new keypoint classes
	 */
	public class TemplateKeypoint extends KeypointBase
	{

		// <- declare attributes of the keypoint here


		/**
		 * Constructor of the class
		 *
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node passed through this waypoint
		 * @param node Id of the node associated to this keypoint
		 */
		public function TemplateKeypoint(/* attributes of the keypont here */ ms:uint, node:int)
		{
			super(ms, node);
			
			// save the attributes here
		}


		// Declare getters for the attributes of the keypoint here. Example:
		
		// public function get attribute():type { return attribute_; }




	}
}
