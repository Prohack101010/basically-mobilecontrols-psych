package mobile;

import haxe.ds.Map;
import haxe.Json;
import haxe.io.Path;
import openfl.utils.Assets;
import flixel.util.FlxSave;
import flixel.group.FlxSpriteGroup;

using StringTools;

enum ButtonsModes
{
	ACTION;
	DPAD;
	HITBOX;
}

enum ButtonsStates
{
	PRESSED;
	JUST_PRESSED;
	RELEASED;
	JUST_RELEASED;
}

/**
 * A handler for MobileButton.
 * If you don't know what are you doing, do not touch here.
 *
 * @author KralOyuncu 2010x (ArkoseLabs)
 */
class MobileInputHandler extends FlxTypedSpriteGroup<MobileButton>
{
	public static var actionModes:Map<String, MobileButtonsData> = new Map();
	public static var dpadModes:Map<String, MobileButtonsData> = new Map();
	public static var hitboxModes:Map<String, CustomHitboxData> = new Map();
	public static var mobileFolderPath:String = 'mobile/';

	public static var save:FlxSave;

	public static function init(saveName:String, savePath:String, mobilePath:String = 'mobile/', folders:Array<String>, modes:Array<ButtonsModes>)
	{
		save = new FlxSave();
		save.bind(saveName, savePath);
		if (mobilePath != null || mobilePath != '') mobileFolderPath = mobilePath;

		var intNumber:Int = -1;
		for (i in folders) {
			intNumber++;
			switch (modes[intNumber]) {
				case ACTION:
					readDirectoryPart1(mobileFolderPath + i, actionModes, ACTION);
				case DPAD:
					readDirectoryPart1(mobileFolderPath + i, dpadModes, DPAD);
				case HITBOX:
					readDirectoryPart1(mobileFolderPath + i, hitboxModes, HITBOX);
			}
		}
	}

	static function readDirectoryPart1(folder:String, map:Dynamic, mode:ButtonsModes)
	{
		folder = folder.contains(':') ? folder.split(':')[1] : folder;

		#if BMS_FILE_SUPPORT if (FileSystem.exists(folder)) #end
		for (file in readDirectoryPart2(folder))
		{
			if (Path.extension(file) == 'json')
			{
				file = Path.join([folder, Path.withoutDirectory(file)]);

				var str:String;
				#if BMS_FILE_SUPPORT
				if (FileSystem.exists(file))
					str = File.getContent(file);
				else #end
					str = Assets.getText(file);

				if (mode == HITBOX) {
					var json:CustomHitboxData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
					map.set(mapKey, json);
				}
				else if (mode == ACTION || mode == DPAD) {
					var json:MobileButtonsData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
					map.set(mapKey, json);
				}
			}
		}
	}

	static function readDirectoryPart2(directory:String):Array<String>
	{
		var dirs:Array<String> = [];

		#if BMS_FILE_SUPPORT
		return FileSystem.readDirectory(directory);
		#else
		var dirs:Array<String> = [];
		for(dir in Assets.list().filter(folder -> folder.startsWith(directory)))
		{
			@:privateAccess
			for(library in lime.utils.Assets.libraries.keys())
			{
				if(library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
					dirs.push('$library:$dir');
				else if(Assets.exists(dir) && !dirs.contains(dir))
					dirs.push(dir);
			}
		}
		return dirs;
		#end
	}

	public var trackedButtons:Map<String, MobileButton> = new Map<String, MobileButton>();

	public function new()
	{
		super();
		updateTrackedButtons();
	}

	public function buttonPressed(button:Dynamic):Bool
		return checkButtonsState(button, PRESSED);

	public function buttonJustPressed(button:Dynamic):Bool
		return checkButtonsState(button, JUST_PRESSED);

	public function buttonJustReleased(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), JUST_RELEASED);

	function checkButtonsState(Buttons:Array<String>, state:ButtonsStates = JUST_PRESSED):Bool
	{
		if (Buttons == null)
			return false;

		for (button in Buttons) {
			if (trackedButtons.exists(button)) {
				if (state == JUST_RELEASED && trackedButtons.get(button).justReleased ||
				   state == PRESSED && trackedButtons.get(button).pressed ||
				   state == JUST_PRESSED && trackedButtons.get(button).justPressed)
				{
					return true;
				}
			}
		}

		return false;
	}


	public function updateTrackedButtons()
	{
		trackedButtons.clear();
		forEachExists(function(button:MobileButton)
		{
			if (button.IDs != null)
			{
				for (id in button.IDs)
				{
					if (!trackedButtons.exists(id))
						trackedButtons.set(id, button);
				}
			}
		});
	}
}

typedef MobileButtonsData =
{
	buttons:Array<ButtonsData>
}

typedef CustomHitboxData =
{
	hints:Array<HitboxData>
}

typedef HitboxData =
{
	button:String, // the button's name for checking pressed directly.
	buttonIDs:Array<String>, // what Hitbox Button Iad should be used, If you're using a the library for PsychEngine 0.7 Versions, This is useful.
	x:Dynamic, // the button's X position on screen.
	y:Dynamic, // the button's Y position on screen.
	width:Dynamic, // the button's Width on screen.
	height:Dynamic, // the button's Height on screen.
	color:String, // the button color, default color is white.
	returnKey:String, // the button return, default return is nothing but If you're game using a lua scripting this will be useful.
}

typedef ButtonsData =
{
	button:String, // the button's name for checking pressed directly.
	buttonIDs:Array<String>, // what MobileButton Button Iad should be used, If you're using a the library for PsychEngine 0.7 Versions, This is useful.
	graphic:String, // the graphic of the button, usually can be located in the MobilePad xml.
	x:Float, // the button's X position on screen.
	y:Float, // the button's Y position on screen.
	color:String, // the button color, default color is white.
	scale:Null<Float> //the button scale, default scale is 1.
}