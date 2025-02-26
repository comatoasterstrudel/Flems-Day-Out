package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.app.Application;
#if desktop
import Discord.DiscordClient;
#end

class DialogueSubstate extends FlxSubState
{
	var bg:FlxSprite;
	var textBox:FlxSprite;
	var enterKey:FlxSprite;

	var nameText:FlxText;
	var dialogueText:FlxTypeText;

	var charName:String;
	var charText:String;
	var textSpeed:Float;

	var finished:Bool = false;

	public static var dialogueName:String;
	public static var canTalk:Bool = true;
	public static var canEmotion:Bool = true;

	override public function create()
	{
		var dialogueData = Utilities.dataFromTextFile(Paths.txt(dialogueName)); // name - text - speed - emotion (0 stays the same)

		for (i in 0...dialogueData.length)
		{
			var dialogueDataArray:Array<String> = dialogueData[i].split(":");

			charName = dialogueDataArray[0];
			if (!canTalk)
				charText = '...';
			else
				charText = dialogueDataArray[1];

			if (!canTalk)
				textSpeed = 0.3;
			else
				textSpeed = Std.parseFloat(dialogueDataArray[2]);
		}

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.alpha = .2;
		add(bg);

		textBox = new FlxSprite();
		textBox.frames = Paths.getSparrowAtlas('dialogueBox');
		textBox.animation.addByPrefix('Idle', 'idle', 2);
		textBox.animation.play('Idle');
		textBox.antialiasing = true;
		textBox.flipY = true;
		textBox.setGraphicSize(Std.int(textBox.width * .4));
		textBox.updateHitbox();
		textBox.setPosition(-10, -30);
		textBox.scrollFactor.set();
		add(textBox);

		nameText = new FlxText(0, 0, 0, charName, 40);
		nameText.setFormat(Paths.font("Andy.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nameText.borderSize = 2;
		nameText.antialiasing = true;
		nameText.setPosition(210 - nameText.width / 2, 370);
		nameText.scrollFactor.set();
		add(nameText);

		dialogueText = new FlxTypeText(0, 0, 700, charText, 40);
		dialogueText.setFormat(Paths.font("Andy.ttf"), 40, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dialogueText.borderSize = 2;
		dialogueText.antialiasing = true;
		dialogueText.setPosition(80, 100);
		dialogueText.sounds = [FlxG.sound.load(Paths.sound('dialogueType'), 1)];
		dialogueText.completeCallback = finishDialogue;
		dialogueText.scrollFactor.set();
		add(dialogueText);
		dialogueText.start(textSpeed, false, false, [], finishDialogue);

		enterKey = new FlxSprite().loadGraphic(Paths.image('enterKey'));
		enterKey.setGraphicSize(Std.int(enterKey.width * 1));
		enterKey.updateHitbox();
		enterKey.setPosition(FlxG.width - enterKey.width - 5, FlxG.height - enterKey.height - 5);
		enterKey.antialiasing = true;
		enterKey.scrollFactor.set();
		add(enterKey);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			if (finished)
			{
				FlxG.sound.play(Paths.sound('dialogueClose'), 1);
				closeMenu();
			}
			else
			{
				FlxG.sound.play(Paths.sound('dialogueSkip'), 1);
				dialogueText.skip();
				finished = true;
			}
		}

		super.update(elapsed);
	}

	function finishDialogue():Void
	{
		finished = true;
	}

	function closeMenu():Void
	{
		var dialogueData = Utilities.dataFromTextFile(Paths.txt(dialogueName)); // name - text - speed - emotion (0 stays the same)

		for (i in 0...dialogueData.length)
		{
			var dialogueDataArray:Array<String> = dialogueData[i].split(":");
			if (canEmotion)
				PlayState.changeEmotion(Std.parseInt(dialogueDataArray[3]));
		}

		if (canEmotion && canTalk)
			PlayState.npcsTalkedTo++;

		close();
	}
}
