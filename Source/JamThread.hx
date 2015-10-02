package;

import cpp.vm.Thread;

class JamThread
{
	var _thread:Thread;
	var _msgCb:Dynamic->Void;

	public function new(mainLoop:Dynamic->Dynamic, msgCb:Dynamic->Void = null)
	{
		_msgCb = msgCb;
		_thread = Thread.create(function ():Void {
			var msg:Dynamic = Thread.readMessage(true);
			if (msg == null || msg.id == null || msg.main == null)
			{
				trace("Improperly formatted first message: " + msg);
				return;
			}

			var id:Int = msg.id;
			var mainThread:Thread = msg.main;

			while (true)
			{
				msg = Thread.readMessage(true);
				var retMsg:Dynamic = mainLoop(msg);
				mainThread.sendMessage({id: id, msg: retMsg});
			}
		});
	}

	public function sendMessage(msg:Dynamic)
	{
		_thread.sendMessage(msg);
	}

	public function processMessage(msg:Dynamic):Void
	{
		if (_msgCb != null) _msgCb(msg);
	}
}
