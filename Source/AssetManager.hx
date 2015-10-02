package;

import openfl.net.URLLoader;
import openfl.net.URLRequest;
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
		_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.addEventListener(Event.COMPLETE, onComplete);

		getAssetFiles();
	}

	private function getAssetFiles():Void
	{
		_loader.load(new URLRequest("https://s3.amazonaws.com/cinemnb/tars/150.tar"));
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
