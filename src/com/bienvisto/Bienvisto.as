package com.bienvisto
{
	import com.bienvisto.core.Simulation;
	import com.bienvisto.core.parser.TraceSourceParser;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.model.WaypointMobilityModel;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.io.FileReferenceReader;
	import com.bienvisto.io.Reader;
	import com.bienvisto.view.VisualizerView;
	import com.bienvisto.view.drawing.NodesDrawingManager;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	
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
			this.window = window; 
		}
		
		private var app:Application;
		private var window:ApplicationWindow;
		
		private var view:VisualizerView;
		
		private var simulation:Simulation;
		private var mobilityModel:WaypointMobilityModel;
		private var nodeContainer:NodeContainer;
		private var mobility:Mobility;
		private var transmissions:Transmissions;
		
		
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
			
			mobilityModel = new WaypointMobilityModel();
			nodeContainer   = new NodeContainer(mobilityModel);
			mobility = new Mobility(nodeContainer, mobilityModel);
			transmissions = new Transmissions(nodeContainer);
			
			simulation.addSimulationObject(nodeContainer);
			simulation.addSimulationObject(mobility);
			simulation.addSimulationObject(transmissions);
			
			reader = new FileReferenceReader();
			parser = new TraceSourceParser(reader);
			
			parser.addTraceSource(simulation);
			parser.addTraceSource(nodeContainer);
			parser.addTraceSource(mobility);
			parser.addTraceSource(transmissions);
			
			// Setup the view
			// 1. Append nodes
			view = window.visualizerView;
			view.setNodeContainer(nodeContainer);
			
			// 2.  
			
			// 2. Append drawing managers
/*			view.addDrawingManager(
				new NodesDrawingManager()
			);*/
			// view.addDrawingManager(
			//	new TopologyDrawingManager()
			// );
			
			// 3. Append components
			// view.addComponent()…;
		}
		
		/**
		 * Bind window
		 * 
		 * @param window
		 */ 
		private function bindWindow(window:ApplicationWindow):void
		{
			window.menu.browseFile.addEventListener(MouseEvent.CLICK, handleBrowseFileClick);
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
		 * Handle browse file click
		 * 
		 * @param event
		 */ 
		private function handleBrowseFileClick(event:MouseEvent):void
		{
			reader.browse();
		}
	}
}