package com.bienvisto
{
	import com.bienvisto.core.Simulation;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.core.parser.TraceSourceParser;
	import com.bienvisto.elements.buffer.Buffers;
	import com.bienvisto.elements.drops.Drops;
	import com.bienvisto.elements.mobility.Mobility;
	import com.bienvisto.elements.mobility.MobilityArea;
	import com.bienvisto.elements.mobility.Waypoint2D;
	import com.bienvisto.elements.network.graph.AdjacencyMatrix;
	import com.bienvisto.elements.network.graph.Graph;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.elements.receptions.Receptions;
	import com.bienvisto.elements.routing.Routing;
	import com.bienvisto.elements.routing.RoutingProtocol;
	import com.bienvisto.elements.routing.RoutingTable;
	import com.bienvisto.elements.routing.RoutingTableEntry;
	import com.bienvisto.elements.routing.SimpleRoute;
	import com.bienvisto.elements.sequences.SequencesRecv;
	import com.bienvisto.elements.sequences.SequencesSent;
	import com.bienvisto.elements.topology.Topology;
	import com.bienvisto.elements.transmissions.Transmissions;
	import com.bienvisto.io.FileReferenceReader;
	import com.bienvisto.io.Reader;
	import com.bienvisto.ui.menu.Playback;
	import com.bienvisto.ui.menu.PlaybackContainer;
	import com.bienvisto.ui.menu.ProgressTimeSlider;
	import com.bienvisto.view.VisualizerView;
	import com.bienvisto.view.components.GridView;
	import com.bienvisto.view.components.LoaderView;
	import com.bienvisto.view.components.NodeSprite;
	import com.bienvisto.view.components.NodeView;
	import com.bienvisto.view.drawing.NodeBuffersDrawingManager;
	import com.bienvisto.view.drawing.NodeDrawingManager;
	import com.bienvisto.view.drawing.NodeDropsDrawingManager;
	import com.bienvisto.view.drawing.NodeIDDrawingManager;
	import com.bienvisto.view.drawing.NodeMobilityDrawingManager;
	import com.bienvisto.view.drawing.NodeReceptionsDrawingManager;
	import com.bienvisto.view.drawing.NodeRoutingDrawingManager;
	import com.bienvisto.view.drawing.NodeTransmissionsDrawingManager;
	import com.bienvisto.view.events.NodeSpriteEvent;
	
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
		}
		
		private var app:Application;
		private var window:ApplicationWindow;
		
		private var view:VisualizerView;
		
		private var simulation:Simulation;
		private var nodeContainer:NodeContainer;
		private var mobility:Mobility;
		private var mobilityArea:MobilityArea;
		private var transmissions:Transmissions;
		private var receptions:Receptions;
		private var drops:Drops;
		private var buffers:Buffers;
		private var routing:Routing;
		private var routingProtocol:RoutingProtocol;
		private var topology:Topology;
		private var sequencesSent:SequencesSent;
		private var sequencesRecv:SequencesRecv;
		
		private var parser:TraceSourceParser;
		private var reader:FileReferenceReader;
	
		private var nodeView:NodeView;
		private var gridView:GridView;
		private var loaderView:LoaderView;
		private var nodeIDDrawingManager:NodeDrawingManager;
		private var mobilityDrawingManager:NodeMobilityDrawingManager;
		private var transmissionsDrawingManager:NodeTransmissionsDrawingManager;
		private var receptionsDrawingManager:NodeReceptionsDrawingManager;
		private var dropsDrawingManager:NodeDropsDrawingManager;
		private var routingDrawingManager:NodeRoutingDrawingManager;
		private var buffersDrawingManager:NodeBuffersDrawingManager;
		
		/**
		 * Setup
		 */ 
		private function setup(window:ApplicationWindow):void
		{
			simulation 	  = new Simulation();
			simulation.addEventListener(Simulation.READY, handleSimulationReady);
			simulation.addEventListener(Simulation.RESET, handleSimulationReset);
			simulation.addEventListener(Simulation.COMPLETE, handleSimulationComplete);
			simulation.addEventListener(TimerEvent.TIMER, handleSimulationTimer);
			
			
			nodeContainer = new NodeContainer();
			
			mobility 	  = new Mobility(nodeContainer);
			mobilityArea  = new MobilityArea();
			
			transmissions = new Transmissions(nodeContainer);
			receptions	  = new Receptions(nodeContainer);
			drops		  = new Drops(nodeContainer);
			buffers		  = new Buffers(nodeContainer);
			
			routing		    = new Routing(nodeContainer);
			routingProtocol = new RoutingProtocol();
			topology		= new Topology(nodeContainer);
			
			sequencesSent = new SequencesSent(nodeContainer);
			sequencesRecv = new SequencesRecv(nodeContainer);
			
			simulation.addSimulationObject(nodeContainer);
			simulation.addSimulationObject(mobility);
			// simulation.addSimulationObject(topology);
			simulation.addSimulationObject(transmissions);
			simulation.addSimulationObject(receptions);
			simulation.addSimulationObject(drops);
			simulation.addSimulationObject(buffers);
			simulation.addSimulationObject(routing);
			// simulation.addSimulationObject(routingProtocol);
			simulation.addSimulationObject(topology);
			simulation.addSimulationObject(sequencesSent);
			simulation.addSimulationObject(sequencesRecv);
			
			reader = new FileReferenceReader();
			parser = new TraceSourceParser(reader);
			
			parser.addTraceSource(simulation);
			parser.addTraceSource(nodeContainer);
			parser.addTraceSource(mobility);
			parser.addTraceSource(transmissions);
			parser.addTraceSource(receptions);
			parser.addTraceSource(drops);
			parser.addTraceSource(buffers);
			parser.addTraceSource(routing);
			parser.addTraceSource(routingProtocol);
			parser.addTraceSource(topology);
			parser.addTraceSource(sequencesSent);
			parser.addTraceSource(sequencesRecv);
			
			parser.addEventListener(TimedEvent.ELAPSED, handleParserTimedEventElapsed);
			parser.addEventListener(Event.COMPLETE, handleParserEventComplete);
			
			// Setup the view
			// 1. Append nodes
			view = window.visualizerView;
			
			// Add views
			// 2. The grid
			// 3. The nodes
			gridView = new GridView();
			view.addViewComponent(gridView);
			
			loaderView = new LoaderView();
			view.setLoaderView(loaderView);
			
			nodeView = new NodeView(nodeContainer)
			view.addViewComponent(nodeView);
			view.setDraggableView(nodeView);
			
			// 3 Append node drawing managers
			nodeIDDrawingManager = new NodeIDDrawingManager();
			nodeView.addDrawingManager(nodeIDDrawingManager);
			
			mobilityDrawingManager = new NodeMobilityDrawingManager(mobility);
			nodeView.addDrawingManager(mobilityDrawingManager);
			
			receptionsDrawingManager = new NodeReceptionsDrawingManager(receptions);
			nodeView.addDrawingManager(receptionsDrawingManager);
			
			transmissionsDrawingManager = new NodeTransmissionsDrawingManager(transmissions, nodeView);
			nodeView.addDrawingManager(transmissionsDrawingManager);
			
			dropsDrawingManager = new NodeDropsDrawingManager(drops);
			nodeView.addDrawingManager(dropsDrawingManager);
			
			buffersDrawingManager = new NodeBuffersDrawingManager(buffers);
			nodeView.addDrawingManager(buffersDrawingManager);
			
			routingDrawingManager = new NodeRoutingDrawingManager(routing, nodeView);
			nodeView.addDrawingManager(routingDrawingManager);
		}
		
		/**
		 * Bind window
		 * 
		 * @param window
		 */ 
		private function bindWindow(window:ApplicationWindow):void
		{
			window.menu.browseFileButton.addEventListener(MouseEvent.CLICK, handleBrowseFileClick);
			window.playback.playbackSpeed.addEventListener(Event.CHANGE, handlePlaybackSpeedChange);
			window.playback.addEventListener(Playback.PLAY, handlePlayButtonStateChange);
			window.playback.addEventListener(Playback.PAUSE, handlePlayButtonStateChange);

			window.playback.addEventListener(TimedEvent.ELAPSED, handlePlaybackProgressTimerElapsed);
			window.playback.addEventListener(ProgressTimeSlider.CHANGE_START, handlePlaybackProgressTimerChangeStart);
			window.playback.addEventListener(ProgressTimeSlider.CHANGE_END, handlePlaybackProgressTimerChangeEnd);
			window.playback.addEventListener(ProgressTimeSlider.LOAD_START, handlePlaybackProgressTimerLoadStart);
			window.playback.addEventListener(ProgressTimeSlider.LOAD_END, handlePlaybackProgressTimerLoadEnd);
			
			
			// window menu add toggeable node drawing managers
			window.menu.addToggeableNodeDrawingManager(nodeIDDrawingManager);
			window.menu.addToggeableNodeDrawingManager(buffersDrawingManager);
			window.menu.addToggeableNodeDrawingManager(transmissionsDrawingManager);
			window.menu.addToggeableNodeDrawingManager(receptionsDrawingManager);
			window.menu.addToggeableNodeDrawingManager(dropsDrawingManager);
			window.menu.addToggeableNodeDrawingManager(routingDrawingManager);
			window.menu.addToggeableNodeDrawingManager(routingDrawingManager.selectedDrawingManager);
			window.menu.addToggeableNodeDrawingManager(routingDrawingManager.betweenNodesDrawingManager);
			
			// window playback set misc view components
			window.playback.addZoomView(gridView);
			window.playback.addZoomView(nodeView);
			window.playback.setGridView(gridView);
			window.playback.gridViewVisible = false;
			
			// window nodeWindows set the trace source components
			window.nodeWindows.setMobility(mobility);
			window.nodeWindows.setRouting(routing);
			window.nodeWindows.setBuffers(buffers);
			window.nodeWindows.setTransmissions(transmissions);
			window.nodeWindows.setReceptions(receptions);
			window.nodeWindows.setDrops(drops);
			window.nodeWindows.setSequencesRecv(sequencesRecv);
			window.nodeWindows.setSequencesSent(sequencesSent);
			
			// window nodeWindows set the node view
			window.nodeWindows.setNodeView(nodeView);
			
			window.menu.debugButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
				debug();
			});
		}
		
		/**
		 * Update time
		 */ 
		private function updateTime():void
		{
			var time:uint = simulation.time; 
			window.playback.setTime(time);
			window.nodeWindows.setTime(time);
			view.setTime(time);
		}
		
		/**
		 * Jump to time
		 * 
		 * @param elapsed
		 */ 
		private function jumpToTime(elapsed:uint):void
		{
			simulation.jumpToTime(elapsed);
			updateTime();
		}
		
		private function debug():void
		{
			var graph:Graph = routing.getGlobalGraph(simulation.time);
			trace("-- Graph ---");
			trace(graph);
			
			var adjacencyMatrix:AdjacencyMatrix = graph.getAdjacencyMatrix();
			
			trace("-- AdjacencyMatrix ---");
			trace(adjacencyMatrix);
			
			trace("-- Adjacent Vertices ---");
			
			var vertices:Vector.<int> = adjacencyMatrix.vertices;
			var size:int 			  = adjacencyMatrix.size;
			var vertex:int;
			for (var i:int = 0; i < size; i++) {
				vertex = vertices[i];
				trace("vertex:", vertex, "adjacent vertices:", adjacencyMatrix.getAdjacentVertices(vertex));
			}
			
/*			trace("app WxH:", app.width, app.height);
			trace("window WxH", window.width, window.height);*/
			
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
		private function handlePlayButtonStateChange(event:Event):void
		{	
			if (!simulation.running) {
				simulation.start();
			}
			else {
				simulation.pause();
			}
		}
		
		/**
		 * Handle playback speed change
		 * 
		 * @param event
		 */ 
		private function handlePlaybackSpeedChange(event:Event):void
		{
			simulation.speed = window.playback.playbackSpeed.value;
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
			updateTime();
		}
		
		/**
		 * Handle simulation complete
		 * 
		 * @param event
		 */ 
		private function handleSimulationComplete(event:Event):void
		{
			window.playback.playButtonState = Playback.PLAY;
		}
		
		/**
		 * Handle parser timed event elapsed
		 * 
		 * @param event
		 */ 
		private function handleParserTimedEventElapsed(event:TimedEvent):void
		{
			if (simulation.duration > 0) {
				var value:Number = event.elapsed / simulation.duration * 100;
				window.playback.setLoaded(value);
				simulation.setLoaded(value);
			}
		}
		
		/**
		 * Handle parser event complete
		 * 
		 * @param event
		 */ 
		private function handleParserEventComplete(event:Event):void
		{
			window.playback.setLoaded(100);	
			simulation.setLoaded(100);
		}
		
		/**
		 * Handle playback progress timer change value
		 * 
		 * @param event
		 */ 
		private function handlePlaybackProgressTimerElapsed(event:TimedEvent):void
		{
			if (!window.playback.buffering) {
				jumpToTime(event.elapsed);
			}
		}

		/**
		 * Handle playback progress timer change start
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerChangeStart(event:Event):void
		{
			if (simulation.running) {
				simulation.pause();
			}
		}
		
		/**
		 * Handle playback progress timer change end
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerChangeEnd(event:Event):void
		{
			if (!window.playback.buffering) {
				jumpToTime(window.playback.getTime());
				if (window.playback.isPlaying && !simulation.running) {
					simulation.start();
				}
			}
		}
		
		/**
		 * Handle playback timer load start
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerLoadStart(event:Event):void
		{
			if (simulation.running) {
				simulation.pause();
			}
		}
		
		/**
		 * Handle playback progress timer load start
		 * 
		 * @param event
		 */
		private function handlePlaybackProgressTimerLoadEnd(event:Event):void
		{
			jumpToTime(window.playback.getTime());
			if (window.playback.isPlaying && !simulation.running) {
				simulation.start();
			}
		}
			
	}
}