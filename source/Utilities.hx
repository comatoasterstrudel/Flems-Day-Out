package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.utils.Assets;
import openfl.Assets;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

class Utilities
{
	// this shit took me 4 hours :(
	public static function dataFromTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if desktop
		if (FileSystem.exists(path))
			daList = File.getContent(path).split('\n');
		#end
		#if html5
		daList = Assets.getText(path).split('\n');
		#end
		return daList;
	}
}
