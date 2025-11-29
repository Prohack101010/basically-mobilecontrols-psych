# Basically Mobile Controls

---

A library for making easier to add Mobile Controls into your game.

---

- [Setup](docs/SETUP.md)
- [Features](docs/FEATURES.md)
- [Usage](#usage)

---

# USAGE

Creating & Handling a mobile controls should be fairly easy and very much self-explanatory

- NOTE: MobilePad & Hitbox Using the same base, so their handling is almost same

```haxe
// *
// * src/Main.hx
// *

import mobile.MobileInputHandler;

class Main {
	static function main():Void {
		MobileInputHandler.init('MobileControls', 'ArkoseLabs/HaxeTale', 'mobile/',
			[
				'MobilePad/DPadModes',
				'MobilePad/ActionModes',
				'Hitbox/HitboxModes',
			], [
				DPAD,
				ACTION,
				HITBOX
			]
		);
	}
}

// *
// * src/PlayState.hx
// *

import mobile.MobilePad;
import mobile.JoyStick;
import mobile.Hitbox;

class PlayState extends FlxState {
	public var mobilePad:MobilePad;
	public var joyStick:JoyStick;
	public var hitbox:Hitbox;
	override function create() {
		// MobilePad
		mobilePad = new MobilePad('Test', 'Test');
		var mobilePadCam:FlxCamera = new FlxCamera();
		mobilePadCam.bgColor.alpha = 0;
		FlxG.cameras.add(mobilePadCam, false);
		mobilePad.buttonCameras = [mobilePadCam];
		add(mobilePad);

		// Hitbox
		hitbox = new Hitbox('Test');
		var hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, false);
		hitbox.buttonCameras = [hitboxCam];
		add(hitbox);

		// JoyStick
		joyStick = new JoyStick(0, 0, 0, 0.25, 0.7); //Params: x, y, radius, ease, size
		var joyStickCam = new FlxCamera();
		joyStickCam.bgColor.alpha = 0;
		FlxG.cameras.add(joyStickCam, false);
		joyStick.cameras = [joyStickCam];
		add(joyStick);
	}
	override function update(elapsed:Float) {
		if (mobilePad.getButtonFromName.get('buttonA').justPressed) {
			trace('hello from buttonA');
		}

		if (hitbox.getButtonFromName.get('buttonUp').justPressed) {
			trace('hello from buttonUp');
		}

		if (joyStick.joyStickPressed('up')) {
			trace('hello from joyStick up');
		}
	}
}

// *
// * src/Controls.hx
// *

import flixel.FlxG;

class Controls {
	public var requestedInstance(get, default):Dynamic;
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
	public static var mobileBinds:Map<String, Array<String>> = [
		'up'			=> ['buttonUp'],
		'left'			=> ['buttonLeft'],
		'down'			=> ['buttonDown'],
		'right'			=> ['buttonRight']
	];

	public function new() {}
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
		return mobilePadJustPressed(mobileBinds[keyName]) || joyStickJustPressed(keyName);
	}
	public function pressed(keyName:String) {
		return mobilePadPressed(mobileBinds[keyName]) || joyStickPressed(keyName);
	}
	public function released(keyName:String) {
		return mobilePadJustReleased(mobileBinds[keyName]) || joyStickJustReleased(keyName);
	}
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

```
