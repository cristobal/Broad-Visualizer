package com.bienvisto
{
	import com.bienvisto.core.Simulation;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.parser.TraceSourceParser;
	import com.bienvisto.elements.buffer.Buffers;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.Waypoint2D;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.io.FileReferenceReader;
	import com.bienvisto.io.Reader;
	import com.bienvisto.view.VisualizerView;
	import com.bienvisto.view.components.GridView;
	import com.bienvisto.view.components.NodeView;
	import com.bienvisto.view.drawing.NodeBufferDrawingManager;
	import com.bienvisto.view.drawing.NodeDropsDrawingManager;
	import com.bienvisto.view.drawing.NodeMobilityDrawingManager;
	import com.bienvisto.view.drawing.NodeReceptionsDrawingManager;
	import com.bienvisto.view.drawing.NodeTransmissionsDrawingManager;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.Timer;
	
	import spark.components.Application;

	/**
	 * Bienvisto
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Bienvisto
	{
		/**
		 * Constructor
		 * 
		 * @param app
		 * @param window
		 */ 
		public function Bienvisto(app:Application, window:ApplicationWindow)
		{		
			setup(window);
			bindWindow(window);
			
			this.app 	= app;
			this.app.frameRate = 24;
			this.window = window; 
			// trace("frameRate", app.frameRate);
		}
		
		private var app:Application;
		private var window:ApplicationWindow;
		
		private var view:VisualizerView;
		
		private var simulation:Simulation;
		private var nodeContainer:NodeContainer;
		private var mobility:Mobility;
		private var transmissions:Transmissions;
		private var receptions:Receptions;
		private var drops:Drops;
		private var buffers:Buffers;
		
		private var parser:TraceSourceParser;
		private var reader:FileReferenceReader;

		/**
		 * Setup
		 */ 
		private function setup(window:ApplicationWindow):void
		{
			
			simulation 	  = new Simulation();
			simulation.addEventListener(Simulation.READY, handleSimulationReady);
			simulation.addEventListener(Simulation.RESET, handleSimulationReset);
			simulation.addEventListener(TimerEvent.TIMER, handleSimulationTimer);
			simulation.addEventListener(TimerEvent.TIMER_COMPLETE, handleSimulationTimerComplete);
			
			nodeContainer = new NodeContainer();
			mobility 	  = new Mobility(nodeContainer);
			transmissions = new Transmissions(nodeContainer);
			receptions	  = new Receptions(nodeContainer);
			drops		  = new Drops(nodeContainer);
			buffers		  = new Buffers(nodeContainer);
				
			simulation.addSimulationObject(nodeContainer);
			simulation.addSimulationObject(mobility);
			simulation.addSimulationObject(transmissions);
			simulation.addSimulationObject(receptions);
			simulation.addSimulationObject(drops);
			simulation.addSimulationObject(buffers);
			
			reader = new FileReferenceReader();
			parser = new TraceSourceParser(reader);
			
			parser.addTraceSource(simulation);
			parser.addTraceSource(nodeContainer);
			parser.addTraceSource(mobility);
			parser.addTraceSource(transmissions);
			parser.addTraceSource(receptions);
			parser.addTraceSource(drops);
			parser.addTraceSource(buffers);
			
			// Setup the view
			// 1. Append nodes
			view = window.visualizerView;
			
			// Add views
			// 2. The grid
			// 3. The nodes
			view.addViewComponent(
				new GridView()
			);
			
			var nodeView:NodeView = new NodeView(nodeContainer)
			view.addViewComponent(nodeView);
			
			// Node view append drawing managers
			// 3. Topology 
			nodeView.addDrawingManager(
				new NodeMobilityDrawingManager(mobility)
			);
			nodeView.addDrawingManager(
				new NodeReceptionsDrawingManager(receptions)
			);
			nodeView.addDrawingManager(
				new NodeTransmissionsDrawingManager(transmissions)
			);
			nodeView.addDrawingManager(
				new NodeDropsDrawingManager(drops)
			);
			nodeView.addDrawingManager(
				new NodeBufferDrawingManager(buffers)
			);
			
		}
		
		/**
		 * Bind window
		 * 
		 * @param window
		 */ 
		private function bindWindow(window:ApplicationWindow):void
		{
			window.menu.browseFile.addEventListener(MouseEvent.CLICK, handleBrowseFileClick);
			window.playback.playButton.addEventListener(MouseEvent.CLICK, handlePlayButtonClick);
		}
		
		
		/**
		 * Handle browse file click
		 * 
		 * @param event
		 */ 
		private function handleBrowseFileClick(event:MouseEvent):void
		{
			reader.browse();
		}
		
		/**
		 * Handle play button click
		 * 
		 * @param event
		 */ 
		private function handlePlayButtonClick(event:MouseEvent):void
		{	
			if (!simulation.running) {
				simulation.start();
			}
			else {
				simulation.pause();
			}
		}
		
		
		/**
		 * Handle simulation ready
		 * 
		 * @param event
		 */ 
		private function handleSimulationReady(event:Event):void
		{
			window.playback.setDuration(
				simulation.duration
			);
		}
		
		/**
		 * Handle simulation reset
		 * 
		 * @param event
		 */ 
		private function handleSimulationReset(event:Event):void
		{
			// Global Reset
		}
		
		/**
		 * Handle simulation timer
		 * 
		 * @param event
		 */ 
		private function handleSimulationTimer(event:TimerEvent):void
		{
			var time:uint = simulation.time; 
			window.playback.setTime(time);
			view.setTime(time);
		}
		
		/**
		 * Handle simulation timer complete
		 * 
		 * @param event
		 */ 
		private function handleSimulationTimerComplete(event:TimerEvent):void
		{
			var timer:Timer = Timer(event.target);
			// trace("timer complete", timer.delay, timer.repeatCount);
		}
	}
}