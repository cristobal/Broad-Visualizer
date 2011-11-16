package com.bienvisto.core
{
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * Simulation.as
	 * 
	 * A represenation of the simulation.
	 * Also a trace source parser for the simulation properties from the trace file.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Simulation extends TraceSource
	{
		//--------------------------------------------------------------------------
		//
		// Constants
		//
		//-------------------------------------------------------------------------
		/**
		 * @public
		 */ 
		[Event(name="ready", type="Event")]
		public static const READY:String = "ready";
		
		/**
		 * @public
		 */ 
		[Event(name="reset", type="Event")]
		public static const RESET:String = "reset";

		//--------------------------------------------------------------------------
		//
		// Class variables
		//
		//-------------------------------------------------------------------------
		/**
		 * @private 
		 */ 
		private static var defaultUpdateRate:uint = 30;
		
		//--------------------------------------------------------------------------
		//
		// Constructor
		//
		//-------------------------------------------------------------------------
		
		/**
		 * Simulation
		 */ 
		public function Simulation()
		{
			super("Simulation", "s");
			setup();
		}
		
		
		//--------------------------------------------------------------------------
		//
		// Variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private var timer:Timer;
		
		/**
		 * @private
		 */ 
		private var firstRun:Boolean = true;
		
		/**
		 * @private
		 */ 
		private var simulationObjects:Vector.<ISimulationObject>;
		
		//--------------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------------

		/**
		 * @private
		 */ 
		private var _duration:uint;
		
		/**
		 * @readonly duration
		 */ 
		public function get duration():uint
		{
			return _duration;
		}
		
		/**
		 * Set duration
		 * 
		 * @param value 
		 */ 
		private function setDuration(value:uint):void
		{
			_duration = value;
			invalidate();
		}
		
		/**
		 * @private
		 */ 
		private var _updateRate:uint = defaultUpdateRate;
		
		/**
		 * @readonly duration
		 */ 
		public function get updateRate():uint
		{
			return _updateRate;
			
		}
		
		/**
		 * Set duration
		 * 
		 * @param value 
		 */ 
		private function setUpdateRate(value:uint):void
		{
			_updateRate = value;
		}
		
		/**
		 * @private timerDelay
		 */
		private function get timerDelay():Number 
		{
			return _duration / 1000;
		}
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		private function setup():void
		{
			simulationObjects = new Vector.<ISimulationObject>();
			
			timer = new Timer(timerDelay);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
		}
		
		private function invalidate():void
		{
			// if this is a new simulation then do a global reset
			if (!firstRun) {
				dispatchEvent(new Event(RESET));
			}
			
			
			dispatchEvent(new Event(READY));
			firstRun = false;
		}
		
		/**
		 * Add a simulation object
		 * 
		 * @param
		 */
		public function addSimulationObject(item:ISimulationObject):void
		{
			simulationObjects.push(item);
		}
		
		/**
		 * Remove a simulation object
		 * 
		 * @param item
		 */ 
		public function removeSimulationObject(item:ISimulationObject):void
		{
			var value:ISimulationObject;
			for (var i:int = simulationObjects.length; i--;) {
				value = simulationObjects[i];
				if (value == item) {
					simulationObjects.splice(i, 1);
					break;
				}
			}
		}
			
		
		/**
		 * Start
		 */ 
		public function start():void
		{
			if (timer.running) {
				return;
			}

			timer.delay = timerDelay; // update timerDelay in case it has changed
			timer.start();
		}
		
		/**
		 * Pause
		 */ 
		public function pause():void
		{
			timer.stop();	
		}
		
		/**
		 * Jump to
		 * 
		 * @param time
		 */ 
		public function jumpTo(time:uint):void
		{
			
		}
		
		/**
		 * Update 
		 * 
		 * @param params
		 */ 
		override public function update(params:Vector.<String>):void
		{
			// FORMAT: s <duration> 
			var duration:uint = uint(params[0]);
			setDuration(duration);	
		}
		
		/**
		 * Handle timer
		 * 
		 * @param event
		 */ 
		private function handleTimer(event:TimerEvent):void
		{
			var elapsed:uint = timer.delay * timer.currentCount;
			var simulationObject:ISimulationObject;
			for (var i:int = 0, l:int = simulationObjects.length; i < l; i++) {
				simulationObject.onTimeUpdate(elapsed);
			}
		}
	}
}