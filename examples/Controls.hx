package;

import flixel.FlxG;

class Controls {
	// walk shitttts
	public var LEFT:Bool = false;
	public var RIGHT:Bool = false;
	public var UP:Bool = false;
	public var DOWN:Bool = false;
	public var LEFT_P:Bool = false;
	public var RIGHT_P:Bool = false;
	public var UP_P:Bool = false;
	public var DOWN_P:Bool = false;
	public var LEFT_R:Bool = false;
	public var RIGHT_R:Bool = false;
	public var UP_R:Bool = false;
	public var DOWN_R:Bool = false;

	public function new() {}

	public static var mobileBinds:Map<String, Array<String>> = [
		'up'			=> ['buttonUp'],
		'left'			=> ['buttonLeft'],
		'down'			=> ['buttonDown'],
		'right'			=> ['buttonRight']
	];

	public function initInput() {
		LEFT = justPressed('left');
		RIGHT = justPressed('right');
		UP = justPressed('up');
		DOWN = justPressed('down');
		LEFT_P = pressed('left');
		RIGHT_P = pressed('right');
		UP_P = pressed('up');
		DOWN_P = pressed('down');
		LEFT_R = released('left');
		RIGHT_R = released('right');
		UP_R = released('up');
		DOWN_R = released('down');
	}

	public function justPressed(keyName:String) {
		return justPressedKeys(mobilePadJustPressed(mobileBinds[keyName]) || joyStickJustPressed(keyName);
	}

	public function pressed(keyName:String) {
		return mobilePadPressed(mobileBinds[keyName]) || joyStickPressed(keyName);
	}
	
	public function released(keyName:String) {
		return mobilePadJustReleased(mobileBinds[keyName]) || joyStickJustReleased(keyName);
	}
	
	// KEYS
	public function justPressedKeys(keyses:Array<FlxKey>) {
		return FlxG.keys.anyJustPressed(keyses);
	}

	public function pressedKeys(keyses:Array<FlxKey>) {
		return FlxG.keys.anyPressed(keyses);
	}

	public function releasedKeys(keyses:Array<FlxKey>) {
		return FlxG.keys.anyJustReleased(keyses);
	}

	public var requestedInstance(get, default):Dynamic;
	public var mobileControls(get, never):Bool;

	private function joyStickPressed(key:String):Bool
	{
		if (key != null && requestedInstance.joyStick != null)
			if (requestedInstance.joyStick.joyStickPressed(key) == true)
				return true;

		return false;
	}

	private function joyStickJustPressed(key:String):Bool
	{
		if (key != null && requestedInstance.joyStick != null)
			if (requestedInstance.joyStick.joyStickJustPressed(key) == true)
				return true;

		return false;
	}

	private function joyStickJustReleased(key:String):Bool
	{
		if (key != null && requestedInstance.joyStick != null)
			if (requestedInstance.joyStick.joyStickJustReleased(key) == true)
				return true;

		return false;
	}

	private function mobilePadPressed(keys:Array<String>):Bool
	{
		if (keys != null && requestedInstance.mobilePad != null)
			if (requestedInstance.mobilePad.buttonPressed(keys) == true)
				return true;

		return false;
	}

	private function mobilePadJustPressed(keys:Array<String>):Bool
	{
		if (keys != null && requestedInstance.mobilePad != null)
			if (requestedInstance.mobilePad.buttonJustPressed(keys) == true)
				return true;

		return false;
	}

	private function mobilePadJustReleased(keys:Array<String>):Bool
	{
		if (keys != null && requestedInstance.mobilePad != null)
			if (requestedInstance.mobilePad.buttonJustReleased(keys) == true)
				return true;

		return false;
	}

	@:noCompletion
	private function get_requestedInstance():Dynamic
	{
		return PlayState.instance;
	}
}