package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;

/**
 * A virtual thumbstick - useful for input on mobile devices.
 *
 * @author Ka Wing Chin
 * @modification author KralOyuncu2010x (ArkoseLabs) to make handling easier
 */
class JoyStick extends FlxSpriteGroup
{
	/**
	 * The minimum input threshold required for horizontal movement recognition.
	 * Values below this threshold will be ignored (dead zone).
	 */
	public var deadZone = {x: 0.3, y: 0.3};

	/**
	 * Shows the current state of the button.
	 */
	public var status:Int = NORMAL;

	public var thumb:FlxSprite;

	/**
	 * The background of the joystick, also known as the base.
	 */
	public var base:FlxSprite;

	/**
	 * This function is called when the button is released.
	 */
	public var onUp:Void->Void;

	/**
	 * This function is called when the button is pressed down.
	 */
	public var onDown:Void->Void;

	/**
	 * This function is called when the touch goes over the button.
	 */
	public var onOver:Void->Void;

	/**
	 * This function is called when the button is hold down.
	 */
	public var onPressed:Void->Void;

	/**
	 * Used with public variable status, means not highlighted or pressed.
	 */
	static inline var NORMAL:Int = 0;

	/**
	 * Used with public variable status, means highlighted (usually from touch over).
	 */
	static inline var HIGHLIGHT:Int = 1;

	/**
	 * Used with public variable status, means pressed (usually from touch click).
	 */
	static inline var PRESSED:Int = 2;

	/**
	 * A list of analogs that are currently active.
	 */
	static var analogs:Array<JoyStick> = [];

	/**
	 * The current pointer that's active on the analog.
	 */
	var currentTouch:FlxTouch;

	/**
	 * Helper array for checking touches
	 */
	var tempTouches:Array<FlxTouch> = [];

	/**
	 * The area which the joystick will react.
	 */
	var zone:FlxRect = FlxRect.get();

	/**
	 * The radius in which the stick can move.
	 */
	var radius:Float = 0;

	/**
	 * The current direction angle of the joystick in radians.
	 * Range: -π to π (-3.14 to 3.14)
	 * 
	 * Direction reference (may be inaccurate):
	 * - 0 radians = Right (→)
	 * - π/2 radians (1.57) = Down (↓) 
	 * - π radians (3.14) = Left (←)
	 * - -π/2 radians (-1.57) = Up (↑)
	 * - π/4 radians (0.79) = Down-Right (↘)
	 * - 3π/4 radians (2.36) = Down-Left (↙)
	 * - -3π/4 radians (-2.36) = Up-Left (↖)
	 * - -π/4 radians (-0.79) = Up-Right (↗)
	 */
	public var inputAngle:Float = 0;

	/**
	 * The current intensity/amount of the joystick input.
	 * Range: 0 to 1, where 0 is no input and 1 is maximum input.
	 */
	public var intensity:Float = 0;

	/**
	 * The speed of easing when the thumb is released.
	 */
	var easeSpeed:Float;

	/**
	 * The current size of JoyStick sprites.
	 */
	public var size(default, set):Float = 1;
	function set_size(Value:Float) {
		size = Value;
		base.scale.set(Value, Value);
		thumb.scale.set(Value, Value);

		if (base != null && radius == 0)
			radius = (base.width * 0.5) * Value;

		zone.set(x - radius, y - radius, 2 * radius, 2 * radius);
		return Value;
	}

	/**
	 * Create a virtual thumbstick - useful for input on mobile devices.
	 *
	 * @param   X			The X-coordinate of the point in space.
	 * @param   Y			The Y-coordinate of the point in space.
	 * @param   Radius		The radius where the thumb can move. If 0, half the base's width will be used.
	 * @param   Ease		Used to smoothly back thumb to center. Must be between 0 and (FlxG.updateFrameRate / 60).
	 * @param   Size			The Scale of the point in space.
	 */
	public function new(X:Float = 0, Y:Float = 0, Radius:Float = 0, Ease:Float = 0.25, Size:Float = 1)
	{
		super(X, Y);

		radius = Radius;
		easeSpeed = FlxMath.bound(Ease, 0, 60 / FlxG.updateFramerate);

		analogs.push(this);

		_point = FlxPoint.get();

		createBase();
		createThumb();
		createZone();
		size = Size;

		scrollFactor.set();
		moves = false;
	}

	/**
	 * Creates the background of the analog stick.
	 */
	function createBase():Void
	{
		base = new FlxSprite(0, 0);

		var xmlFile:String = MobileConfig.mobileFolderPath + 'JoyStick/joystick.xml';
		var pngFile:String = MobileConfig.mobileFolderPath + 'JoyStick/joystick.png';
		#if BSM_FILE_SUPPORT
		var xmlAndPngExists:Bool = false;
		if(FileSystem.exists(xmlFile) && FileSystem.exists(pngFile)) xmlAndPngExists = true;

		if (xmlAndPngExists)
			base.loadGraphic(FlxGraphic.fromFrame(BitmapData.fromFile(pngFile), File.getContent(xmlFile)).getByName('base'));
		else #end
			base.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(Assets.getBitmapData(pngFile), Assets.getText(xmlFile)).getByName('base')));

		base.resetSizeFromFrame();
		base.x += -base.width * 0.5;
		base.y += -base.height * 0.5;
		base.scrollFactor.set();
		base.solid = false;
		#if FLX_DEBUG
		base.ignoreDrawDebug = true;
		#end
		add(base);
	}

	/**
	 * Creates the thumb of the analog stick.
	 */
	function createThumb():Void
	{
		thumb = new FlxSprite(0,0);

		var xmlFile:String = MobileConfig.mobileFolderPath + 'JoyStick/joystick.xml';
		var pngFile:String = MobileConfig.mobileFolderPath + 'JoyStick/joystick.png';
		#if BSM_FILE_SUPPORT
		var xmlAndPngExists:Bool = false;
		if(FileSystem.exists(xmlFile) && FileSystem.exists(pngFile)) xmlAndPngExists = true;

		if (xmlAndPngExists)
			thumb.loadGraphic(FlxGraphic.fromFrame(BitmapData.fromFile(pngFile), File.getContent(xmlFile)).getByName('thumb'));
		else #end
			thumb.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(Assets.getBitmapData(pngFile), Assets.getText(xmlFile)).getByName('thumb')));

		thumb.resetSizeFromFrame();
		thumb.x += -thumb.width * 0.5;
		thumb.y += -thumb.height * 0.5;
		thumb.scrollFactor.set();
		thumb.solid = false;
		#if FLX_DEBUG
		thumb.ignoreDrawDebug = true;
		#end
		add(thumb);
	}

	/**
	 * Creates the touch zone. It's based on the size of the background.
	 * The thumb will react when the touch is in the zone.
	 */
	public function createZone():Void
	{
		if (base != null && radius == 0)
			radius = base.width * 0.5;

		zone.set(x - radius, y - radius, 2 * radius, 2 * radius);
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();

		zone = FlxDestroyUtil.put(zone);

		analogs.remove(this);
		onUp = null;
		onDown = null;
		onOver = null;
		onPressed = null;
		thumb = null;
		base = null;

		currentTouch = null;
		tempTouches = null;
	}

	/**
	 * Update the behavior.
	 */
	override public function update(elapsed:Float):Void
	{
		var offAll:Bool = true;

		// There is no reason to get into the loop if their is already a pointer on the analog
		if (currentTouch != null)
		{
			tempTouches.push(currentTouch);
		}
		else
		{
			for (touch in FlxG.touches.list)
			{
				var touchInserted:Bool = false;

				for (analog in analogs)
				{
					// Check whether the pointer is already taken by another analog.
					// TODO: check this place. This line was 'if (analog != this && analog.currentTouch != touch && touchInserted == false)'
					if (analog == this && analog.currentTouch != touch && !touchInserted)
					{
						tempTouches.push(touch);
						touchInserted = true;
					}
				}
			}
		}

		for (touch in tempTouches)
		{
			_point.set(touch.screenX, touch.screenY);

			if (!updateAnalog(_point, touch.pressed, touch.justPressed, touch.justReleased, touch))
			{
				offAll = false;
				break;
			}
		}

		if ((status == HIGHLIGHT || status == NORMAL) && intensity != 0)
		{
			intensity -= intensity * easeSpeed * FlxG.updateFramerate / 60;

			if (Math.abs(intensity) < 0.1)
			{
				intensity = 0;
				inputAngle = 0;
			}
		}

		thumb.x = x + Math.cos(inputAngle) * intensity * radius - (thumb.width * 0.5);
		thumb.y = y + Math.sin(inputAngle) * intensity * radius - (thumb.height * 0.5);

		if (offAll)
			status = NORMAL;

		tempTouches.splice(0, tempTouches.length);

		super.update(elapsed);
	}

	function updateAnalog(TouchPoint:FlxPoint, Pressed:Bool, JustPressed:Bool, JustReleased:Bool, Touch:FlxTouch):Bool
	{
		var offAll:Bool = true;

		if (zone.containsPoint(TouchPoint) || (status == PRESSED))
		{
			offAll = false;

			if (Pressed)
			{
				if (Touch != null)
					currentTouch = Touch;

				status = PRESSED;

				if (JustPressed && onDown != null)
					onDown();

				if (status == PRESSED)
				{
					if (onPressed != null)
						onPressed();

					var dx:Float = TouchPoint.x - x;
					var dy:Float = TouchPoint.y - y;

					var dist:Float = Math.sqrt(dx * dx + dy * dy);

					if (dist < 1)
						dist = 0;

					inputAngle = Math.atan2(dy, dx);
					intensity = Math.min(radius, dist) / radius;

					acceleration.x = Math.cos(inputAngle) * intensity;
					acceleration.y = Math.sin(inputAngle) * intensity;
				}
			}
			else if (JustReleased && status == PRESSED)
			{
				currentTouch = null;

				status = HIGHLIGHT;

				if (onUp != null)
					onUp();

				acceleration.set();
			}

			if (status == NORMAL)
			{
				status = HIGHLIGHT;

				if (onOver != null)
					onOver();
			}
		}

		return offAll;
	}

	/**
	 * Whether the thumb is pressed or not.
	 */
	public var pressed(get, never):Bool;

	inline function get_pressed():Bool
	{
		return status == PRESSED;
	}

	/**
	 * Whether the thumb is just pressed or not.
	 */
	public var justPressed(get, never):Bool;

	function get_justPressed():Bool
	{
		if (currentTouch != null)
			return currentTouch.justPressed && status == PRESSED;

		return false;
	}

	/**
	 * Whether the thumb is just released or not.
	 */
	public var justReleased(get, never):Bool;

	function get_justReleased():Bool
	{
		if (currentTouch != null)
			return currentTouch.justReleased && status == HIGHLIGHT;

		return false;
	}

	override public function set_x(X:Float):Float
	{
		super.set_x(X);
		createZone();

		return X;
	}

	override public function set_y(Y:Float):Float
	{
		super.set_y(Y);
		createZone();

		return Y;
	}

	/**
	 * Whether the joystick is pointing up.
	 */
	public var up(get, never):Bool;
	
	function get_up():Bool
	{
		if (!pressed) return false;
		return intensity > deadZone.y && (Math.sin(inputAngle) < -deadZone.y);
	}
	
	/**
	 * Whether the joystick is pointing down.
	 */
	public var down(get, never):Bool;
	
	function get_down():Bool
	{
		if (!pressed) return false;
		return Math.sin(inputAngle) > deadZone.y;
	}
	
	/**
	 * Whether the joystick is pointing left.
	 */
	public var left(get, never):Bool;
	
	function get_left():Bool
	{
		if (!pressed) return false;
		return Math.cos(inputAngle) < -deadZone.x;
	}
	
	/**
	 * Whether the joystick is pointing right.
	 */
	public var right(get, never):Bool;
	
	function get_right():Bool
	{
		if (!pressed) return false;
		return Math.cos(inputAngle) > deadZone.x;
	}

	/**
	 * Check if a specific direction was just pressed.
	 * @param Direction The direction to check ('up', 'down', 'left', 'right')
	 * @param Threshold Minimum amount required (0-1). Default is 0.5.
	 * @return Bool
	 */
	public function joyStickJustPressed(Direction:String, Threshold:Float = 0.5):Bool
	{
		if (!justPressed) return false;
		
		switch (Direction.toLowerCase())
		{
			case 'up':
				return up;
			case 'down':
				return down;
			case 'left':
				return left;
			case 'right':
				return right;
			default:
				//trace('Invalid direction: ' + Direction + '. Use: up, down, left, right');
				return false;
		}
	}
	
	/**
	 * Check if a specific direction is currently held.
	 * @param Direction The direction to check ('up', 'down', 'left', 'right')
	 * @param Threshold Minimum amount required (0-1). Default is 0.5.
	 * @return Bool
	 */
	public function joyStickPressed(Direction:String, Threshold:Float = 0.5):Bool
	{
		if (!pressed) return false;

		switch (Direction.toLowerCase())
		{
			case 'up':
				return up;
			case 'down':
				return down;
			case 'left':
				return left;
			case 'right':
				return right;
			default:
				//trace('Invalid direction: ' + Direction + '. Use: up, down, left, right');
				return false;
		}
	}
	
	/**
	 * Check if a specific direction was just released.
	 * @param Direction The direction to check ('up', 'down', 'left', 'right')
	 * @param Threshold Minimum amount required (0-1). Default is 0.5.
	 * @return Bool
	 */
	public function joyStickJustReleased(Direction:String, Threshold:Float = 0.5):Bool
	{
		if (!justReleased) return false;

		switch (Direction.toLowerCase())
		{
			case 'up':
				return up;
			case 'down':
				return down;
			case 'left':
				return left;
			case 'right':
				return right;
			default:
				//trace('Invalid direction: ' + Direction + '. Use: up, down, left, right');
				return false;
		}
	}
}