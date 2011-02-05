
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.managers.PopUpManager;
import mx.collections.ArrayList;
import mx.events.SandboxMouseEvent;
import mx.charts.series.AreaSeries;
import mx.charts.series.LineSeries;
import mx.graphics.Stroke;

import com.bienvisto.core.Tools;
import com.bienvisto.core.VariableBase;
import com.bienvisto.core.Visualizer;

/**
 * Vector containing all series currently represented in a graph
 */
protected var series_:Array = new Array();
/**
 * Array of all registered variables
 */
protected var variables_:Array = new Array();
/**
 * Vector containing the ids of all selected nodes
 */
protected var selectedNodes_:Vector.<int>;


public const lineColors:Array = new Array(0x0000ff,
											0x00ff00,
											0xff0000,
											0xf6ff00,
											0xbb00ff,
											0xff7300,
											0xff0095);

/**
 * Used to control the drag and drop resizing of the window
 */
private var clickOffset:Point;
/**
 * Width of the window when the user started resizing the window
 */
private var previousWidth:Number;
/**
 * Height of the window when the user started resizing the window
 */
private var previousHeight:Number;


/**
 * Sets the minimum resolution allowed when drawing the graph
 *
 * @param value Resolution of the graph in milliseconds
 */
public function set minResolution(value:Number):void
{
	resolutionSlider.minimum = value;
	resolutionSlider.stepSize = (resolutionSlider.maximum - resolutionSlider.minimum)/1000;
}
public function get minResolution():Number
{
	return resolutionSlider.minimum;
}
/**
 * Sets the maximum resolution allowed when drawing the graph
 *
 * @param value Resolution of the graph in milliseconds
 */
public function set maxResolution(value:Number):void
{
	resolutionSlider.maximum = value;
	resolutionSlider.stepSize = (resolutionSlider.maximum - resolutionSlider.minimum)/1000;
}
public function get maxResolution():Number
{
	return resolutionSlider.maximum;
}


/**
 * Sets the selected nodes. These nodes will be used to filter the 
 * represented variable. If null, all nodes will be represented
 */
public function set selectedNodes(v:Vector.<int>):void
{
	selectedNodes_ = v;
	updateGraph();
}


/**
 * Sets the progress of the simulation that is being displayed. This is 
 * used to draw a line indicating the visualized moment in the graph
 *
 * @param v Progress of the simulation being displayed. For instance,
 * if it is being displayed the fifth minute in a ten minutes long
 * simulation, this progress would be 0.5
 */
public function set timeProgress(v:Number):void
{
	chartAnnotations.graphics.clear();
	chartAnnotations.graphics.beginFill(0xbb3366);
	chartAnnotations.graphics.drawRect(v*chartAnnotations.width, 0, 2, chartAnnotations.height);
	chartAnnotations.graphics.endFill();
}


/**
 * Sets a vector of variables that can be represented in this stats
 * window. The user will choose among these using a combobox
 */
public function set variables(vars:Vector.<VariableBase>):void
{
	variables_ = new Array();
	varSelector.dataProvider = new ArrayList();
	for each (var variable:VariableBase in vars)
	{
		variables_[variable.name] = variable;
		varSelector.dataProvider.addItem(variable.name);
	}
}


public function cleanUp():void
{
	series_ = null;
	selectedNodes_ = null;
	
	removeEventListener("enterFrame", updateTime);
	resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN, resizeMouseDown);
	if (Visualizer.instance)
		Visualizer.instance.removeEventListener(Visualizer.NODE_CLICKED,
			updateSelectedNodes);
}


/**
 * Initializes the component
 */
protected function initComponent():void
{
	updateSelectedNodes(null);
	
	addEventListener("enterFrame", updateTime);
	addEventListener("close", closeWindow);
	
	if (Visualizer.instance)
		Visualizer.instance.addEventListener(Visualizer.NODE_CLICKED,
			updateSelectedNodes);
	
	resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, resizeMouseDown);
}


protected function updateTime(e:Event):void
{
	if (Visualizer.instance != null)
		timeProgress = Visualizer.instance.simulationProgress;
}
protected function updateSelectedNodes(e:Event):void
{
	if (Visualizer.topology != null)
		selectedNodes = Visualizer.topology.selectedNodes;
}


/**
 * Updates the graph. Should be called when the resolution or the
 * selected nodes change
 */
protected function updateGraph(e:Event = null):void
{
	var variable:VariableBase;
	
	for (var i:int = 0; i < series_.length; i++)
	{
		variable = variables_[series_[i].serie.displayName];
		series_[i].serie.dataProvider = variable.getValues(resolutionSlider.value, selectedNodes_);
	}
	updateSeries();
}


/**
 * Adds a new variable to the chart
 */
protected function addVariable():void
{
	if (varSelector.selectedItem == null)
		return;
	
	var variable:VariableBase = variables_[varSelector.selectedItem];
	var color:uint = lineColors[series_.length%lineColors.length];
	
	var label:VariableLabel = new VariableLabel(variable.name, color);
	label.addEventListener(VariableLabel.REMOVE, removeVariable);
	
	this.varsContainer.addElement(label);
	
	minResolution = Math.max(minResolution, variable.minimumResolution);
	maxResolution = Math.min(maxResolution, variable.maximumResolution);
	
	var newSerie:LineSeries = new LineSeries(); 
	newSerie.dataProvider = variable.getValues(resolutionSlider.value, selectedNodes_);
	newSerie.xField = "hAxis";
	newSerie.yField = "vAxis";
	newSerie.displayName = variable.name;
	newSerie.setStyle("lineStroke", new Stroke(color, 2));

	series_.push({label: label, serie: newSerie});

	updateSeries();
}


/**
 * Removes a variable from the chart
 */
protected function removeVariable(e:Event):void
{
	var label:VariableLabel = VariableLabel(e.target);
	
	for (var i:int = 0; i < series_.length && series_[i].label != label; i++) {}
	
	if (i < series_.length)
		series_.splice(i, 1);
	
	updateSeries();
	
	label.removeEventListener(VariableLabel.REMOVE, removeVariable);
	
	this.varsContainer.removeElement(label);
}


/**
 * Updates the chart so that it contains all the selected series
 */
protected function updateSeries():void
{
	var newSeries:Array = new Array();
	for each (var s:Object in series_)
	{
		newSeries.push(s.serie);
	}
	chart.series = newSeries;
}


protected function resizeMouseDown(e:MouseEvent):void
{
	if (!clickOffset)
	{
		clickOffset = new Point(e.stageX, e.stageY);
		previousWidth = width;
		previousHeight = height;
		
		var root:DisplayObject = systemManager.getSandboxRoot();
		
		root.addEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMove,
			true);
		root.addEventListener(MouseEvent.MOUSE_UP, resizeMouseUp,
			true);
		root.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,
			resizeMouseUp);
	}
}


protected function resizeMouseMove(e:MouseEvent):void
{
	e.stopImmediatePropagation();
	
	if (!clickOffset)
		return;
	
	width = previousWidth + (e.stageX - clickOffset.x);
	height = previousHeight + (e.stageY - clickOffset.y);
	e.updateAfterEvent();
}


protected function resizeMouseUp(e:Event):void
{
	clickOffset = null;
	
	var root:DisplayObject = systemManager.getSandboxRoot();
	
	root.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMove,
		true);
	root.removeEventListener(MouseEvent.MOUSE_UP, resizeMouseUp,
		true);
	root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,
		resizeMouseUp);
}


protected function closeWindow(e:Event):void
{
	cleanUp();
	
	PopUpManager.removePopUp(this);
}
