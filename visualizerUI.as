

import mx.managers.PopUpManager;

import flash.events.ProgressEvent;
import flash.utils.getTimer;
import flash.geom.Point;

import spark.components.HGroup;
import spark.components.Label;
import spark.components.CheckBox;

import UIComponents.charts.ChartsWindow;
import UIComponents.LoadingWindow;

import core.Tools;

import elements.ElementBase;


protected static const MENU_HEIGHT:int = 50;
protected static const LOG_HEIGHT:int = 100;

protected static const OPTIONS_HEIGHT:int = 60;
protected static const OPTIONS_OFFSET:int = 40;

protected var fileHelper:FileHelper = new FileHelper();

protected var loadingWindow:LoadingWindow = new LoadingWindow();

protected var paused:Boolean = true;

// The following two vars are used to control the scrolling by drag and drop
protected var lastDragX:Number = -1;
protected var lastDragY:Number = -1;

/**
 * Time when some loading process started
 */
protected var loadStart_:uint;



/**
 * Initializes all needed variables and adds some event listeners
 */
public function initApp():void
{
	addEventListener(MouseEvent.MOUSE_DOWN, startDragScroll);
	addEventListener(MouseEvent.MOUSE_UP, stopDragScroll);
	
	v.addEventListener(Visualizer.FINISHED, visualizationFinished);
	v.addEventListener(Visualizer.LOAD_START, loadStart);
	v.addEventListener(Visualizer.LOAD_COMPLETE, loadComplete);
	v.addEventListener(Visualizer.LOAD_PROGRESS, loadProgress);
}


/**
 * Function called each time the app enters a new frame. Updates the UI and 
 * calls the update function in the visualizer
 */
public function enterFrame(e:Event):void
{
	validateNow();
	
	if(v.ready) v.update((paused ? 0.0 : playbackSpeed.value));
	
	timeSlider.value = v.simulationProgress*1000;
	timeLabel.text = Tools.millisecondsToText(v.simulationTime) 
		+ " / "
		+ Tools.millisecondsToText(v.simulationLength);
}


/**
 * Opens a new charts window
 */
public function openChartsWindow():void
{
	if (v != null)
	{
		var charts:ChartsWindow = ChartsWindow(PopUpManager.createPopUp(this, ChartsWindow));
		charts.variables = v.getVariables();
	}
}


/**
 * Hides or shows the log
 */
public function toggleLog():void
{
	if (menu.bottom == -LOG_HEIGHT) menuAnimation.play();
	else { menuAnimation.play(null, true); }
}

/**
 * Hides or shows the options panel
 */
public function toggleOptions():void
{
	if (options.top == -OPTIONS_HEIGHT-OPTIONS_OFFSET) optionsAnimation.play();
	else { optionsAnimation.play(null, true); }
}


/**
 * Plays or pauses the visualization
 */
public function togglePlayback():void
{
	paused = !paused;
	
	if (!paused)
	{
		playButton.label = "Pause";
	}
	else
	{ 
		playButton.label = "Play";
	}
}


/**
 * Called when the visualizer reaches the end or the beginning of the simulation
 */
public function visualizationFinished(e:Event):void
{
	togglePlayback();
}


/**
 * Called when the visualizer starts loading something and displays the
 * loading window in front of everything
 */
public function loadStart(e:Event):void
{
	updateVisibleElements();
	
	timeSlider.enabled = false;
	
	PopUpManager.addPopUp(loadingWindow, this, false);
	//PopUpManager.centerPopUp(loadingWindow);
	loadingWindow.x = timeSlider.x;
	loadingWindow.y = timeSlider.parent.localToGlobal(new Point(0, timeSlider.y)).y - 12;
	loadingWindow.progress.indeterminate = true;
	
	loadStart_ = getTimer();
}

/**
 * Called when the visualizer makes some progress while loading something. This
 * function updates the progress displayed in the progress bar while loading
 */
public function loadProgress(e:ProgressEvent):void
{
	if (loadingWindow.progress.indeterminate)
	{
		updateVisibleElements();
		loadingWindow.progress.indeterminate = false;
	}
	loadingWindow.progress.setProgress(e.bytesLoaded, e.bytesTotal);
	
	loadingWindow.progress.label = Math.round((e.bytesLoaded/e.bytesTotal)*100) 
		+ "% of " + Math.round(e.bytesTotal/(1024*1024)) + " MB";
	
	var remaining:int = (e.bytesTotal*(getTimer() - loadStart_))/e.bytesLoaded;
	remaining -= getTimer() - loadStart_;
	
	loadingWindow.progress.label += " (" + Tools.msToShortString(remaining)
		+ " remaining)";
}

/**
 * Called when the visualizer finishes loading something and removes the
 * loading window
 */
public function loadComplete(e:Event):void
{
	updateVisibleElements();
	PopUpManager.removePopUp(loadingWindow);
	timeSlider.enabled = true;
}


public function startDragScroll(e:MouseEvent):void
{
	if (!e.ctrlKey)
		return;
	
	lastDragX = e.stageX;
	lastDragY = e.stageY;
	
	addEventListener(MouseEvent.MOUSE_MOVE, updateDragScroll);
}
public function updateDragScroll(e:MouseEvent):void
{
	var zoomFactor:Number = 1/(zoomLevel.value / 100.0);
	v.targetX -= zoomFactor*(e.stageX - lastDragX);
	v.targetY -= zoomFactor*(e.stageY - lastDragY);
	
	lastDragX = e.stageX;
	lastDragY = e.stageY;
}
public function stopDragScroll(e:MouseEvent):void
{
	removeEventListener(MouseEvent.MOUSE_MOVE, updateDragScroll);
}


public function timeSliderChanged():void
{
	// Calculate the time corresponding to the value of the time slider
	var newTime:uint = v.simulationLength * (timeSlider.value / 1000);
	
	// Tell the visualizer to jump to that instant
	v.jumpTo(newTime);
}

public function zoomLevelChanged():void
{
	v.zoom = zoomLevel.value / 100.0;
	grid.scale = v.zoom;
}


public function updateGrid():void
{
	grid.visible = showGridCheckbox.selected;
}

/**
 * Updates the visibility of the elements in the options window
 */
protected function updateVisibleElements():void
{
	var elements:Vector.<ElementBase> = v.elements;
	
	while (visibleElements.numChildren > 0)
		visibleElements.removeElementAt(0);
	
	var auxLabel:Label;
	var auxCheckBox:CheckBox;
	var auxGroup:HGroup;
	for each (var element:ElementBase in elements)
	{
		auxGroup = new HGroup();
		
		auxLabel = new Label();
		auxLabel.text = element.name;
		auxLabel.setStyle("fontSize", 14);
		auxLabel.setStyle("paddingTop", 5);
		auxCheckBox = new CheckBox();
		auxCheckBox.selected = true;
		auxCheckBox.addEventListener("change", element.toggleVisibility);
		
		auxGroup.addElement(auxCheckBox);
		auxGroup.addElement(auxLabel);
		visibleElements.addElement(auxGroup);
	}
}



