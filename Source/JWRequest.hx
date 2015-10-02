package; 

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.ErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.HTTPStatusEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLVariables;
import openfl.net.URLRequestMethod;
import openfl.net.URLRequestHeader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.SharedObject;

import haxe.Json;

class JWRequest extends EventDispatcher
{

	private var _loader:URLLoader;
	private var _cb:Dynamic->Void;
	private var _code:Int = -1;

	public function new(url:String, ?method:String = URLRequestMethod.GET, 
						dataFormat:URLLoaderDataFormat = null, 
						?data:Dynamic = null, ?cb:Dynamic->Void = null, 
						?cookies:Array<String> = null) 
	{ 
		super();

		var request:URLRequest = parseRequest(url, method, data, cookies);
		if (request == null)
		{
			trace("Unable to create URLRequest");
			return;
		}

		//request.verbose =	true;
		//if (request.data != null) trace("URL: " + url + " DATA: " + data);

		_loader = new URLLoader();
		if (dataFormat != null) _loader.dataFormat = dataFormat;

		_cb = cb;

		if (_cb != null) addListeners();
		_loader.load(request);
	}
	
	private function parseRequest(url:String, method:String, ?data:Dynamic = null, 
			 				      ?cookies:Array<String> = null):URLRequest
	{
		var request:URLRequest = new URLRequest(url);

		if (method == URLRequestMethod.POST || method == URLRequestMethod.PUT)
			request.contentType = 'application/json';

		request.method = method;

		if (cookies != null)
		{
			request.requestHeaders.push
			(
				new URLRequestHeader("Cookie", cookies.join("; "))
			);
		}

		if (data != null)
		{
			if (Std.is(data, Dynamic))
			{
				try 
				{
					request.data = Json.stringify(data);
				}
				catch (msg:String)
				{
					trace("Unable to stringify data: " + msg);
					return null;
				}
			}
			else
			{
				request.data = data;
			}
		}

		return request;
	}

	private function addListeners():Void
	{
		_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.addEventListener(Event.COMPLETE, onComplete);
		_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
	}

	private function removeListeners():Void
	{
		_loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.removeEventListener(Event.COMPLETE, onComplete);
		_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
	}

	private function onStatus(?e:HTTPStatusEvent):Void
	{
		if (e == null)
		{
			trace("HTTPSTATUS was null");
			return;
		}

		_code = e.status;
	}

	private function onComplete(?e:Event):Void
	{
		removeListeners();
		var cookieStrs:Array<String> = [];//_loader.getCookies();
		var cookies:Array<String> = new Array<String>();
		for (cookieStr in cookieStrs)
		{
			var cookie:String = parseCookie(cookieStr);
			if (cookie != null) cookies.push(cookie);
		}

		var ret:Dynamic = 
		{
			data: _loader.data, 
			code: _code
		};
		if (cookies.length > 0) ret.cookies = cookies;

		if (_code < 200 || _code >= 400)
		{
			ret.err = _loader.data;
		}

		if (_cb != null) _cb(ret);
	}

	private function parseCookie(cookieLine:String):String
	{
		var reg:EReg = ~/\s+/g;
		var fields:Array<String> = reg.split(cookieLine);
		if (fields.length < 2) return null;
		
		return fields[fields.length - 2] + "=" + fields[fields.length -1];
	}

	private function onError(?e:IOErrorEvent):Void
	{
		removeListeners();
		if (_cb != null) _cb({err: e.text, code: e.errorID});
	}
}
