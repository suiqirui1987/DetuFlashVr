﻿/*
 OuWei Flash3DHDView 
*/
package com.panozona.modules.dropdown.controller{
	
	import caurina.transitions.Tweener;
	import com.panozona.modules.dropdown.events.WindowEvent;
	import com.panozona.modules.dropdown.view.WindowView;
	import com.panozona.player.module.data.property.Align;
	import com.panozona.player.module.data.property.Transition;
	import com.panozona.player.module.Module;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	public class WindowController{
		
		private var _windowView:WindowView;
		private var _module:Module;
		
		private var boxController:BoxController;
		
		public function WindowController(windowView:WindowView, module:Module) {
			_module = module;
			_windowView = windowView;
			
			_windowView.windowData.addEventListener(WindowEvent.CHANGED_OPEN, onOpenChange, false, 0, true);
			
			_windowView.windowData.addEventListener(WindowEvent.CHANGED_FINAL_SIZE, onFinalSizeSet, false, 0, true);
			
			boxController = new BoxController(windowView.boxView, module);
			
			var panoramaEventClass:Class = ApplicationDomain.currentDomain.getDefinition("com.panozona.player.manager.events.PanoramaEvent") as Class;
			_module.qjPlayer.manager.addEventListener(panoramaEventClass.PANORAMA_STARTED_LOADING, onPanoramaStartedLoading, false, 0, true);
		}
		
		private function onFinalSizeSet(e:Event):void {
			_windowView.windowData.removeEventListener(WindowEvent.CHANGED_FINAL_SIZE, onFinalSizeSet);
			var ViewEventClass:Class = ApplicationDomain.currentDomain.getDefinition("com.panosalado.events.ViewEvent") as Class;
			_module.qjPlayer.manager.addEventListener(ViewEventClass.BOUNDS_CHANGED, handleResize, false, 0, true);
			handleResize();
		}
		
		private function onPanoramaStartedLoading(loadPanoramaEvent:Object):void {
			var panoramaEventClass:Class = ApplicationDomain.currentDomain.getDefinition("com.panozona.player.manager.events.PanoramaEvent") as Class;
			_module.qjPlayer.manager.removeEventListener(panoramaEventClass.PANORAMA_STARTED_LOADING, onPanoramaStartedLoading);
			if (_windowView.windowData.open){
				_module.qjPlayer.manager.runAction(_windowView.windowData.window.onOpen);
			}else {
				_module.qjPlayer.manager.runAction(_windowView.windowData.window.onClose);
			}
		}
		
		private function handleResize(event:Event = null):void {
			placeWindow();
		}
		
		private function onOpenChange(e:Event):void {
			if (_windowView.windowData.open) {
				_module.qjPlayer.manager.runAction(_windowView.windowData.window.onOpen);
				openWindow();
			}else {
				_windowView.dropDownData.boxData.open = false;
				_module.qjPlayer.manager.runAction(_windowView.windowData.window.onClose);
				closeWindow();
			}
		}
		
		private function openWindow():void {
			_windowView.visible = true;
			_windowView.mouseEnabled = true;
			_windowView.mouseChildren = true;
			var tweenObj:Object = new Object();
			tweenObj["time"] = _windowView.windowData.window.openTween.time;
			tweenObj["transition"] = _windowView.windowData.window.openTween.transition;
			if (_windowView.windowData.window.transition.type == Transition.FADE) {
				tweenObj["alpha"] = _windowView.windowData.window.alpha;
			}else{
				tweenObj["x"] = getWindowOpenX();
				tweenObj["y"] = getWindowOpenY();
			}
			Tweener.addTween(_windowView, tweenObj);
		}
		
		private function closeWindow():void {
			var tweenObj:Object = new Object();
			tweenObj["time"] = _windowView.windowData.window.closeTween.time;
			tweenObj["transition"] = _windowView.windowData.window.closeTween.transition;
			tweenObj["onComplete"] = closeWindowOnComplete;
			if (_windowView.windowData.window.transition.type == Transition.FADE) {
				tweenObj["alpha"] = 0;
			}else{
				tweenObj["x"] = getWindowCloseX();
				tweenObj["y"] = getWindowCloseY();
			}
			_windowView.mouseEnabled = false;
			_windowView.mouseChildren = false;
			Tweener.addTween(_windowView, tweenObj);
		}
		
		private function closeWindowOnComplete():void {
			_windowView.visible = false;
		}
		
		private function placeWindow(e:Event = null):void {
			if (_windowView.windowData.open) {
				Tweener.addTween(_windowView, {x:getWindowOpenX(), y:getWindowOpenY()});  // no time parameter
				_windowView.alpha = _windowView.windowData.window.alpha;
				_windowView.visible = true;
			}else {
				Tweener.addTween(_windowView, {x:getWindowCloseX(), y:getWindowCloseY()}); // no time parameter
				if(_windowView.windowData.window.transition.type == Transition.FADE){
					_windowView.alpha = 0;
				}
				_windowView.visible = false;
			}
		}
		
		private function getWindowOpenX():Number {
			var result:Number = 0;
			switch(_windowView.windowData.window.align.horizontal) {
				case Align.RIGHT:
					result += _module.qjPlayer.manager.boundsWidth 
						- _windowView.windowData.finalSize.width 
						+ _windowView.windowData.window.move.horizontal;
				break;
				case Align.LEFT:
					result += _windowView.windowData.window.move.horizontal;
				break;
				default: // CENTER
					result += (_module.qjPlayer.manager.boundsWidth 
						- _windowView.windowData.finalSize.width) * 0.5 
						+ _windowView.windowData.window.move.horizontal;
			}
			return result;
		}
		
		private function getWindowOpenY():Number{
			var result:Number = 0;
			switch(_windowView.windowData.window.align.vertical) {
				case Align.TOP:
					result += _windowView.windowData.window.move.vertical;
				break;
				case Align.BOTTOM:
					result += _module.qjPlayer.manager.boundsHeight 
						- _windowView.windowData.finalSize.height
						+ _windowView.windowData.window.move.vertical;
				break;
				default: // MIDDLE
					result += (_module.qjPlayer.manager.boundsHeight 
						- _windowView.windowData.finalSize.height) * 0.5
						+ _windowView.windowData.window.move.vertical;
			}
			return result;
		}
		
		private function getWindowCloseX():Number {
			var result:Number = 0;
			switch(_windowView.windowData.window.transition.type){
				case Transition.SLIDE_RIGHT:
					result = _module.qjPlayer.manager.boundsWidth;
				break;
				case Transition.SLIDE_LEFT:
					result = -_windowView.windowData.finalSize.width;
				break;
				default: //SLIDE_UP, SLIDE_DOWN
					result = getWindowOpenX();
			}
			return result;
		}
		
		private function getWindowCloseY():Number{
			var result:Number = 0;
			switch(_windowView.windowData.window.transition.type){
				case Transition.SLIDE_UP:
					result = -_windowView.windowData.finalSize.height;
				break;
				case Transition.SLIDE_DOWN:
					result = _module.qjPlayer.manager.boundsHeight;
				break;
				default: //SLIDE_LEFT, SLIDE_RIGHT
					result = getWindowOpenY();
			}
			return result;
		}
	}
}