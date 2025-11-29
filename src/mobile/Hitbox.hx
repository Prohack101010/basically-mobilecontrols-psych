package mobile;

import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;
import flixel.util.FlxColor;
import flixel.FlxCamera;

/**
 * A zone with custom hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author KralOyuncu 2010x (ArkoseLabs)
 */
class Hitbox extends MobileInputHandler
{
	public var onButtonDown:FlxTypedSignal<(MobileButton, Array<String>) -> Void> = new FlxTypedSignal<(MobileButton, Array<String>) -> Void>();
	public var onButtonUp:FlxTypedSignal<(MobileButton, Array<String>) -> Void> = new FlxTypedSignal<(MobileButton, Array<String>) -> Void>();
	public var instance:MobileInputHandler;
	public var Hints:Array<MobileButton> = [];
	public var buttonIndexFromName:Map<String, Int> = [];
	public var buttonFromName:Map<String, MobileButton> = [];
	public var globalAlpha:Float = 0.7;
	public var buttonCameras(get, set):Array<FlxCamera>;

	public function getButtonIndexFromName(btnName:String)
		return buttonIndexFromName.get(btnName);

	public function getButtonFromName(btnName:String)
		return buttonFromName.get(btnName);

	@:noCompletion
	function get_buttonCameras():Array<FlxCamera>
	{
		return cameras;
	}

	@:noCompletion
	function set_buttonCameras(Value:Array<FlxCamera>):Array<FlxCamera>
	{
		cameras = Value;
		for (button in Hints) {
			button._cameras = Value;
		}
		return Value;
	}

	/**
	 * Create the zone.
	 */
	public function new(Mode:String, globalAlpha:Float = 0.7, ?disableCreation:Bool):Void
	{
		instance = this;
		super();
		this.globalAlpha = globalAlpha;

		if (!disableCreation)
		{
			if (!MobileConfig.hitboxModes.exists(Mode))
				throw 'The HitboxMode "$Mode" doesn\'t exists.';

			for (buttonData in MobileConfig.hitboxModes.get(Mode).hints)
			{
				var buttonName:String = buttonData.button;
				var buttonIDs:Array<String> = buttonData.buttonIDs;
				var buttonX:Float = buttonData.x;
				var buttonY:Float = buttonData.y;

				var buttonWidth:Int = buttonData.width;
				var buttonHeight:Int = buttonData.height;

				var buttonColor = buttonData.color;
				var buttonReturn = buttonData.returnKey;

				addHint(buttonName, buttonIDs, buttonX, buttonY, buttonWidth, buttonHeight, Util.colorFromString(buttonColor), buttonReturn);
			}
		}

		scrollFactor.set();
		updateTrackedButtons();

		instance = this;
	}

	var countedIndex:Int = 0;
	public function addHint(Name:String, IDs:Array<String>, X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF, ?buttonReturn:String)
	{
		var hint = createHint(IDs, X, Y, Width, Height, Color, buttonReturn);
		Hints.push(hint);
		add(hint);
		buttonFromName.set(Name, hint);
		buttonIndexFromName.set(Name, countedIndex);
		countedIndex++;
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF, ?isLane:Bool = false):BitmapData
	{
		var guh:Float = globalAlpha;
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		// Gradient (Example)
		shape.graphics.lineStyle(3, Color, 1);
		shape.graphics.drawRect(0, 0, Width, Height);
		shape.graphics.lineStyle(0, 0, 0);
		shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
		shape.graphics.endFill();
		if (isLane)
			shape.graphics.beginFill(Color);
		else
			shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [guh, 0], [0, 255], null, null, null, 0.5);
		shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	public function createHint(Name:Array<String>, X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF, ?Return:String, ?Map:String):MobileButton
	{
		var hint:MobileButton = new MobileButton(X, Y, Return);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));

		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.IDs = Name;
		hint.onDown.callback = function()
		{
			onButtonDown.dispatch(hint, Name);
			if (hint.alpha != globalAlpha)
				hint.alpha = globalAlpha;
		}
		hint.onOut.callback = hint.onUp.callback = function()
		{
			onButtonUp.dispatch(hint, Name);
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}

	/**
	 * Clean up memory.
	 */
	override function destroy():Void
	{
		super.destroy();
		onButtonUp.destroy();
		onButtonDown.destroy();

		Hints = [];
		buttonIndexFromName = [];
		buttonFromName = [];
	}
}