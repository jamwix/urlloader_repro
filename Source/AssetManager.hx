package;

import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLLoaderDataFormat;
import openfl.events.IOErrorEvent;
import openfl.events.Event;

class AssetManager 
{

	private var _loader:URLLoader;

	public function new()
	{
	}

	public function start()
	{
		_loader = new URLLoader();
		_loader.dataFormat = URLLoaderDataFormat.BINARY;
		_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.addEventListener(Event.COMPLETE, onComplete);

		getAssetFiles();
	}

	private function getAssetFiles():Void
	{
		_loader.load(new URLRequest("http://d1geib4acjj2ck.cloudfront.net/tars/150.tar"));
	}

	private function onComplete(e:Event):Void
	{
		getAssetFiles();
	}

	private function onError(e:Event):Void
	{
		trace("ERROR! That was unexpected...");
	}
}
