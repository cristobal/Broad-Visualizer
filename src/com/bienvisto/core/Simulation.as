package com.bienvisto.core
{
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	/**
	 * @public
	 */ 
	[Event(name="timer", type="flash.events.TimerEvent")]

	/**
	 * @public
	 */ 
	[Event(name="timerComplete", type="flash.events.TimerEvent")]
	
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
		 * @Event
		 */ 
		[Event(name="ready", type="flash.events.Event")]
		public static const READY:String = "ready";
		
		/**
		 * @Event
		 */ 
		[Event(name="reset", type="flash.events.Event")]
		public static const RESET:String = "reset";
		
		//--------------------------------------------------------------------------
		//
		// Class variables
		//
		//-------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private static var timerDelay:Number = 100;
		
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
		 * @readonly running
		 */ 
		public function get running():Boolean
		{
			return timer.running;
		}
		
		/**
		 * @reaonly time
		 */ 
		public function get time():uint
		{
			return uint(timer.currentCount * timer.delay);
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
		 * @readonly repeatCount
		 */ 
		private function get repeatCount():int
		{
			return duration / 10;
		}
		
		//--------------------------------------------------------------------------
		//
		// Methods
		//
		//-------------------------------------------------------------------------
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			simulationObjects = new Vector.<ISimulationObject>();

			timer = new Timer(timerDelay, repeatCount);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
		}
		
		/**
		 * Invalidate
		 */ 
		private function invalidate():void
		{
			// if this is a new simulation then do a global reset
			if (!firstRun) {
				dispatchEvent(new Event(RESET));
			}
			
			
			timer.repeatCount = repeatCount;			
			
			
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
		 * @override
		 */ 
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if ((type == TimerEvent.TIMER) || (type == TimerEvent.TIMER_COMPLETE)) {
				timer.addEventListener(type, listener, useCapture, priority, useWeakReference);	
			}
			else {
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
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
				simulationObject = simulationObjects[i];
				simulationObject.onTimeUpdate(elapsed);
			}
		}
		
		/**
		 * Handle timer complete
		 * 
		 * @param event
		 */ 
		private function handleTimerComplete(event:TimerEvent):void
		{
			// forward the complete event
			// dispatchEvent(event);
		}
	}
}