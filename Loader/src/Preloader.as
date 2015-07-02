package 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.getDefinitionByName;
	import com.adobe.serialization.json.JSON;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author hhg4092
	 */
	public class Preloader extends MovieClip 
	{
		public var loadingPro:MovieClip;
		public var _para:String;
		
		
		public var _loader:Loader = new Loader();
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.SHOW_ALL;
				stage.align = StageAlign.TOP;
			}
			
			//TODO show loader			
			loadingPro = new Link_Loading();
			loadingPro.gotoAndStop(1);			
		    loadingPro._Progress.gotoAndStop(1);			
			addChild(loadingPro);
			
			
			addEventListener(Event.ENTER_FRAME, checkFrame);
		}
		
		private function checkFrame(e:Event):void 
		{
			if (this.loaderInfo.parameters["para"] != undefined)
			{    
				var token:String = this.loaderInfo.parameters["para"];				
				loadingPro._log.text = token;
				_para = token;
			}
			
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			
			// TODO hide loader
			startup();
		}
		
	
		private function startup():void 
		{
			
			var result:Object  = JSON.decode(_para);
			//var UserToken:String= result.data.UserName;
			//loadingPro._log.text = result.game + "?para=" + result;
			
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadend);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, gameprogress);
			var url:URLRequest = new URLRequest(result.game + "?para=" + result);
			
			//var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			var loaderContext:LoaderContext = new LoaderContext(false, new ApplicationDomain());
				
			_loader.load( url, loaderContext);
		}
		
		private function gameprogress(e:ProgressEvent):void 
		{
			// TODO update loader
			var total:Number = Math.round( e.bytesTotal/ 1024);
			var loaded:Number = Math.round(e.bytesLoaded / 1024);
			var percent:Number = Math.round(loaded / total * 100);
			
			loadingPro._Progress.gotoAndStop(percent);
			loadingPro._Progress._Percent._TextFild.text = percent.toString()+"%";
		}
		
		private function loadend(event:Event):void
		{			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadend);
			
			if ( (_loader.content as MovieClip )["pass"] != null)
			{
				var result:Object  = JSON.decode(_para);
				(_loader.content as MovieClip)["pass"](result);				
			}
			
			addChild(_loader);
			removeChild(loadingPro);		
		}
		
	}
	
}