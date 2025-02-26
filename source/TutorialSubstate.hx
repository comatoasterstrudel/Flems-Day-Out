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

class TutorialSubstate extends FlxSubState
{
	var controlAllowed:Bool = true;

	var bg:FlxSprite;
	var paper:FlxSprite;
	var enterKey:FlxSprite;

	var canClick:Bool = false;

	override public function create()
	{
		#if desktop
		DiscordClient.changePresence('Start Menu', null);
		#end

		PlayState.cutsceneFinished = true;
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.alpha = .3;
		bg.scrollFactor.set();
		add(bg);

		FlxG.sound.play(Paths.sound('paperRustle'), 1);

		paper = new FlxSprite().loadGraphic(Paths.image('beginningPage'));
		paper.setGraphicSize(Std.int(paper.width * .6));
		paper.updateHitbox();
		paper.setPosition(FlxG.width / 2 - paper.width / 2, FlxG.height);
		paper.antialiasing = true;
		paper.scrollFactor.set();
		add(paper);
		FlxTween.tween(paper, {y: FlxG.height / 2 - paper.height / 2}, 1, {
			ease: FlxEase.quadInOut,
			onComplete: function(FlxTwn):Void
			{
				canClick = true;
				enterKey.visible = true;
			}
		});

		enterKey = new FlxSprite().loadGraphic(Paths.image('enterKey'));
		enterKey.setGraphicSize(Std.int(enterKey.width * 1));
		enterKey.updateHitbox();
		enterKey.setPosition(FlxG.width - enterKey.width - 5, FlxG.height - enterKey.height - 5);
		enterKey.antialiasing = true;
		enterKey.scrollFactor.set();
		enterKey.visible = false;
		add(enterKey);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.ENTER && canClick)
		{
			FlxG.sound.play(Paths.sound('paperRustle'), 1);
			enterKey.visible = false;
			canClick = false;

			FlxTween.tween(paper, {y: 0 - paper.height}, 1, {
				ease: FlxEase.quadInOut,
				onComplete: function(FlxTwn):Void
				{
					close();
				}
			});
		}

		super.update(elapsed);
	}
}
