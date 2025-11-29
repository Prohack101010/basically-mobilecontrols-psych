package mobile;

import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.graphics.frames.FlxTileFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxCamera;

/**
 * A modified FlxVirtualPad works with IDs.
 * It's really easy to customize the layout.
 *
 * @author KralOyuncu 2010x (ArkoseLabs)
 */
@:access(mobile.MobileButton)
class MobilePad extends MobileInputHandler {
	public var DPads:Array<MobileButton> = [];
	public var Actions:Array<MobileButton> = [];
	public var getButtonIndexFromName:Map<String, Int> = [];
	public var getButtonFromName:Map<String, MobileButton> = [];
	public var instance:MobileInputHandler;
	public var buttonCameras(get, set):Array<FlxCamera>;
	
	@:noCompletion
	function get_buttonCameras():Array<FlxCamera>
	{
		return cameras;
	}

	@:noCompletion
	function set_buttonCameras(Value:Array<FlxCamera>):Array<FlxCamera>
	{
		cameras = Value;
		for (button in DPads) {
			button._cameras = Value;
		}
		for (button in Actions) {
			button._cameras = Value;
		}
		return Value;
	}
	
	/**
	 * Create a virtual gamepad.
	 *
	 * @param   DPadMode   The D-Pad mode. `FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 * @param   GlobalAlpha   The alpha of buttons. `0.7` for example.
	 */

	public function new(DPad:String, Action:String, globalAlpha:Float = 0.7) {
		super();

		if (DPad != "NONE")
		{
			if (!MobileInputHandler.dpadModes.exists(DPad))
				throw 'The mobilePad dpadMode "$DPad" doesn\'t exists.';

			var countedIndex:Int = 0;
			for (buttonData in MobileInputHandler.dpadModes.get(DPad).buttons)
			{
				if (buttonData.scale == null) buttonData.scale = 1.0;
				var buttonName:String = buttonData.button;
				var buttonIDs:Array<String> = buttonData.buttonIDs;
				var buttonGraphic:String = buttonData.graphic;
				var buttonScale:Float = buttonData.scale;
				var buttonColor = buttonData.color;
				var buttonX:Float = buttonData.x;
				var buttonY:Float = buttonData.y;

				var button:MobileButton = new MobileButton(0, 0);
				button = createVirtualButton(buttonIDs, buttonX, buttonY, buttonGraphic, buttonScale, Util.colorFromString(buttonColor));
				button.name = buttonName;
				DPads.push(button);
				add(button);
				getButtonFromName.set(buttonName, button);
				getButtonIndexFromName.set(buttonName, countedIndex);
				countedIndex++;
			}
		}

		if (Action != "NONE")
		{
			if (!MobileInputHandler.actionModes.exists(Action))
				throw 'The mobilePad actionMode "$Action" doesn\'t exists.';

			var countedIndex:Int = 0;
			for (buttonData in MobileInputHandler.actionModes.get(Action).buttons)
			{
				if (buttonData.scale == null) buttonData.scale = 1.0;
				var buttonName:String = buttonData.button;
				var buttonIDs:Array<String> = buttonData.buttonIDs;
				var buttonGraphic:String = buttonData.graphic;
				var buttonColor = buttonData.color;
				var buttonScale:Float = buttonData.scale;
				var buttonX:Float = buttonData.x;
				var buttonY:Float = buttonData.y;

				var button:MobileButton = new MobileButton(0, 0);
				button = createVirtualButton(buttonIDs, buttonX, buttonY, buttonGraphic, buttonScale, Util.colorFromString(buttonColor));
				button.name = buttonName;
				Actions.push(button);
				add(button);
				getButtonFromName.set(buttonName, button);
				getButtonIndexFromName.set(buttonName, countedIndex);
				countedIndex++;
			}
		}

		scrollFactor.set();
		updateTrackedButtons();
		alpha = globalAlpha;

		instance = this;
	}

	public function createVirtualButton(buttonIDs:Array<String>, x:Float, y:Float, framePath:String, ?scale:Float = 1.0, ?ColorS:Int = 0xFFFFFF):MobileButton {
		var frames:FlxGraphic;

		final path:String = MobileInputHandler.mobileFolderPath + 'MobilePad/Textures/$framePath.png';
		if(Assets.exists(path))
			frames = FlxGraphic.fromBitmapData(Assets.getBitmapData(path));
		else
			frames = FlxGraphic.fromBitmapData(Assets.getBitmapData(MobileInputHandler.mobileFolderPath + 'MobilePad/Textures/default.png'));

		var button = new MobileButton(x, y);
		button.scale.set(scale, scale);
		button.frames = FlxTileFrames.fromGraphic(frames, FlxPoint.get(Std.int(frames.width / 2), frames.height));

		button.updateHitbox();
		button.updateLabelPosition();

		button.bounds.makeGraphic(Std.int(button.width - 50), Std.int(button.height - 50), FlxColor.TRANSPARENT);
		button.centerBounds();

		button.immovable = true;
		button.solid = button.moves = false;
		button.antialiasing = true;
		button.tag = framePath.toUpperCase();

		if (ColorS != -1) button.color = ColorS;
		button.IDs = buttonIDs;
		return button;
	}
}