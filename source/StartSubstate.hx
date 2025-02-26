package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class StartSubstate extends FlxSubState
{
	var controlAllowed:Bool = true;

	var bg:FlxSprite;
	var logo:FlxSprite;

	var acceptText:FlxText;

	var menuItems:FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		#if desktop
		DiscordClient.changePresence('Start Menu', null);
		#end
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.alpha = .3;
		menuItems.add(bg);

		logo = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.setGraphicSize(Std.int(logo.width * .4));
		logo.updateHitbox();
		logo.setPosition(FlxG.width / 2 - logo.width / 2, 10);
		logo.antialiasing = true;
		menuItems.add(logo);

		acceptText = new FlxText(0, 0, 0, "Press ENTER to start", 35);
		acceptText.setFormat(Paths.font("Andy.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		acceptText.antialiasing = true;
		acceptText.setPosition(FlxG.width / 2 - acceptText.width / 2, FlxG.height - 75);
		menuItems.add(acceptText);

		fadeIn();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.ENTER && controlAllowed)
		{
			closeMenu();
		}

		super.update(elapsed);
	}

	function fadeIn():Void
	{
		controlAllowed = false;

		var fade:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		fade.alpha = 1;
		add(fade);
		FlxTween.tween(fade, {alpha: 0}, 1, {ease: FlxEase.cubeInOut, onComplete: endFade});
	}

	function endFade(tween:FlxTween):Void
	{
		controlAllowed = true;
	}

	function closeMenu():Void
	{
		controlAllowed = false;
		FlxG.sound.play(Paths.sound('menuAccept'), 1);
		menuItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 0}, 3, {ease: FlxEase.cubeInOut});
		});

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			PlayState.startCutscene();
			close();
		});
	}
}
