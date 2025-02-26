package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class PlayState extends FlxState
{
	public static var musicHappy:FlxSound;
	public static var musicSad:FlxSound;
	public static var musicDepressed:FlxSound;

	public static var camGame:FlxCamera;
	public static var camFollow:FlxPoint;

	public static var flem:FlxSprite;

	public static var bg1:FlxBackdrop;
	public static var bg2:FlxBackdrop;
	public static var sign1:FlxSprite;
	public static var gbPark:FlxSprite;
	public static var spaceKey:FlxSprite;

	public static var darkVignette:FlxSprite;

	public static var emotionNumber:Int = 1; // 1 is happy, 2 is sad, 3 is depressed.

	public static var npcGroup:FlxTypedGroup<FlxSprite>;
	public static var npcOffsetData = Utilities.dataFromTextFile(Paths.txt('npcOffsets')); // each number is each npcs y offset.
	public static var NPCs:Array<String> = [
		'ROADBLOCK', 'WINSTON', 'JAMA', 'TALL', 'NOFACE', 'FLOWER', 'SCREAM', 'LUIGI', 'CAT', 'PUMPKIN', 'COMA', 'CLEM'
	];

	public static var npcsTalkedTo:Int = 1;

	public static var canMove:Bool = false;

	public static var cutsceneFinished:Bool = false;
	public static var inEnding:Bool = false;

	override public function create()
	{
		trace('hi');
		#if desktop
		DiscordClient.initialize();
		updateDiscordStatus();
		#end
		musicHappy = new FlxSound().loadEmbedded(Paths.music('flemSong_1'), true, true);
		musicHappy.play();
		FlxG.sound.list.add(musicHappy);
		musicHappy.volume = 0;

		musicSad = new FlxSound().loadEmbedded(Paths.music('flemSong_2'), true, true);
		musicSad.play();
		FlxG.sound.list.add(musicSad);
		musicSad.volume = 0;

		musicDepressed = new FlxSound().loadEmbedded(Paths.music('flemSong_3'), true, true);
		musicDepressed.play();
		FlxG.sound.list.add(musicDepressed);
		musicDepressed.volume = 0;

		camGame = new FlxCamera();
		camGame.bgColor.alpha = 0;
		bgColor = FlxColor.WHITE;
		FlxG.cameras.add(camGame);

		camFollow = new FlxPoint(FlxG.width / 2, FlxG.height / 2);

		// ok start code here lol

		bg2 = new FlxBackdrop(Paths.image('BG_sky'), XY);
		bg2.scrollFactor.set(.5, .5);
		bg2.cameras = [camGame];
		bg2.antialiasing = true;
		add(bg2);

		bg1 = new FlxBackdrop(Paths.image('BG_grass'), X);
		bg1.y = FlxG.height - bg1.height;
		bg1.scrollFactor.set(1, 1);
		bg1.cameras = [camGame];
		bg1.antialiasing = true;
		add(bg1);

		sign1 = new FlxSprite(10, FlxG.height - 540).loadGraphic(Paths.image('Sign_Movement'));
		sign1.setGraphicSize(Std.int(sign1.width * .55));
		sign1.updateHitbox();
		sign1.antialiasing = true;
		sign1.cameras = [camGame];
		add(sign1);

		gbPark = new FlxSprite().loadGraphic(Paths.image('BG_grobblebergPark'));
		gbPark.setGraphicSize(Std.int(gbPark.width * .45));
		gbPark.updateHitbox();
		gbPark.antialiasing = true;
		gbPark.cameras = [camGame];
		add(gbPark);

		npcGroup = new FlxTypedGroup<FlxSprite>();
		add(npcGroup);

		for (i in 0...NPCs.length)
		{
			var xVal:Int = i + 1;
			var npc:FlxSprite = new FlxSprite(-1000 + (2500 * i), FlxG.height - 450);
			npc.frames = Paths.getSparrowAtlas('npcs/npc_' + NPCs[i]);
			npc.animation.addByPrefix('idle', 'idle', 2);
			npc.animation.addByPrefix('talk', 'talk', 2);
			npc.animation.play('idle');
			npc.setGraphicSize(Std.int(npc.width * .4));
			npc.updateHitbox();
			npc.ID = i;
			npc.antialiasing = true;
			npcGroup.add(npc);

			// offsets so that all the characters are at the same position sort of.
			var yNpcOffset:Array<String> = npcOffsetData[0].split(":");
			npc.y += Std.parseFloat(yNpcOffset[npc.ID]);
			trace(NPCs[npc.ID] + 's Y offset by ' + yNpcOffset[npc.ID]);

			var xNpcOffset:Array<String> = npcOffsetData[1].split(":");
			npc.x += Std.parseFloat(xNpcOffset[npc.ID]);
			trace(NPCs[npc.ID] + 's X offset by ' + xNpcOffset[npc.ID]);

			trace('NPC added, ' + NPCs[i] + ', ' + npc.x + ', ' + npc.y);

			if (npc.ID == NPCs.length - 1) // stuff to do for the last npc
			{
				gbPark.setPosition(npc.x - 200, FlxG.height - gbPark.height); // the park will always be near the last npc

				npc.x += Std.parseFloat(xNpcOffset[npc.ID]); // adds the x offset again so the park wont move with them
				npc.setGraphicSize(Std.int(npc.width * .6));
			}
		}

		spaceKey = new FlxSprite().loadGraphic(Paths.image('spaceKey'));
		spaceKey.setGraphicSize(Std.int(spaceKey.width * 1.2));
		spaceKey.updateHitbox();
		spaceKey.antialiasing = true;
		spaceKey.cameras = [camGame];
		add(spaceKey);

		darkVignette = new FlxSprite().loadGraphic(Paths.image('sadVignette'));
		darkVignette.setGraphicSize(0, FlxG.height);
		darkVignette.updateHitbox();
		darkVignette.screenCenter();
		darkVignette.antialiasing = true;
		darkVignette.alpha = 0;
		darkVignette.scrollFactor.set();

		flem = new FlxSprite();
		flem.frames = Paths.getSparrowAtlas('Flem_Sprites');
		flem.animation.addByPrefix('Idle 1', 'idle_1', 1);
		flem.animation.addByPrefix('Idle 2', 'idle_2', 24);
		flem.animation.addByPrefix('Idle 3', 'idle_3', 24);
		flem.animation.addByPrefix('Move 1', 'move_1', 24);
		flem.animation.addByPrefix('Move 2', 'move_2', 24);
		flem.animation.addByPrefix('Move 3', 'move_3', 24);
		flem.antialiasing = true;
		flem.setGraphicSize(Std.int(flem.width * .25));
		flem.updateHitbox();
		flem.setPosition(-200, FlxG.height - 300);
		flem.cameras = [camGame];
		add(flem);

		add(darkVignette); // gets added last since it has to be over everything.

		// ok stop now

		openSubState(new StartSubstate());

		super.create();
	}

	override public function update(elapsed:Float)
	{
		camGame.focusOn(camFollow);

		if (!cutsceneFinished && canMove)
		{
			openSubState(new TutorialSubstate());
		}

		npcGroup.forEach(function(spr:FlxSprite)
		{
			if (!inEnding)
			{
				spr.animation.play('idle');
			}
		});

		if (!inEnding)
		{
			switch (emotionNumber)
			{
				case 1:
					musicHappy.volume = 1;
					musicSad.volume = 0;
					musicDepressed.volume = 0;
				case 2:
					musicHappy.volume = 0;
					musicSad.volume = 1;
					musicDepressed.volume = 0;
				case 3:
					musicHappy.volume = 0;
					musicSad.volume = 0;
					musicDepressed.volume = 1;
			}
		}

		// movement bahahaha
		if (FlxG.keys.pressed.LEFT && canMove || FlxG.keys.pressed.A && canMove)
		{
			flem.x -= 6;
			camFollow.x -= 6;
			flem.flipX = true;
			flem.animation.play('Move ' + emotionNumber);
		}
		else if (FlxG.keys.pressed.RIGHT && canMove || FlxG.keys.pressed.D && canMove)
		{
			flem.x += 6;
			camFollow.x += 6;
			flem.flipX = false;
			flem.animation.play('Move ' + emotionNumber);
		}
		else if (canMove)
		{
			flem.animation.play('Idle ' + emotionNumber);
		}

		// check if flem is near an npc
		spaceKey.visible = false;

		npcGroup.forEach(function(spr:FlxSprite)
		{
			if (flem.x + flem.width / 2 >= spr.x - 20 && flem.x + flem.width / 2 <= spr.x + spr.width + 20 && canMove)
			{
				spaceKey.visible = true;
				spaceKey.setPosition(spr.x + spr.width / 2 - spaceKey.width / 2, spr.y - spaceKey.height);
				if (spaceKey.y < 0)
				{
					spaceKey.y = 5;
				}

				if (FlxG.keys.pressed.SPACE)
				{
					spaceKey.visible = false;

					if (spr.ID == npcsTalkedTo)
					{
						spr.animation.play('talk');
						startDialogue(NPCs[spr.ID], true, true); // you can talk to this npc
					}
					else if (spr.ID < npcsTalkedTo)
					{
						spr.animation.play('talk');
						startDialogue(NPCs[spr.ID], true, false); // you can talk to this npc but no emotion can be gained
					}
					else
					{
						startDialogue(NPCs[spr.ID], false, false); // you cant talk to this npc
					}
				}
			}

			if (flem.x < spr.x && spr.ID == 0)
			{
				flem.x = spr.x;
				camFollow.x = flem.x + flem.width / 2;
			}
		});

		if (flem.x >= gbPark.x - 250 && canMove && NPCs.length - 1 == npcsTalkedTo)
		{
			startEnding();
		}
		else if (flem.x >= gbPark.x - 250 && canMove && NPCs.length - 1 != npcsTalkedTo)
		{
			flem.x = gbPark.x - 251;
			camFollow.x = flem.x + flem.width / 2;
		}

		super.update(elapsed);
	}

	#if desktop
	function updateDiscordStatus():Void
	{
		var discordStatus:String = 'In Game';

		DiscordClient.changePresence(discordStatus, null);
	}
	#end

	function startDialogue(fileName:String, canTalkTo:Bool, canGetEmotion:Bool):Void
	{
		DialogueSubstate.canTalk = canTalkTo;
		DialogueSubstate.canEmotion = canGetEmotion;
		DialogueSubstate.dialogueName = 'dialogue/' + fileName + '_dialogue';
		openSubState(new DialogueSubstate());
	}

	public static function changeEmotion(nextEmotion:Int):Void
	{
		if (nextEmotion != emotionNumber && nextEmotion != 0) // switch emotion
		{
			emotionNumber = nextEmotion;

			switch (nextEmotion)
			{
				case 1:
					FlxG.sound.play(Paths.sound('emotionHappy'), 1);
					FlxTween.tween(darkVignette, {alpha: 0}, 1.5, {ease: FlxEase.cubeInOut});
				case 2:
					FlxG.sound.play(Paths.sound('emotionSad'), 1);
					FlxTween.tween(darkVignette, {alpha: .25}, 1.5, {ease: FlxEase.cubeInOut});
				case 3:
					FlxG.sound.play(Paths.sound('emotionDepressed'), 1);
					FlxTween.tween(darkVignette, {alpha: .5}, 1.5, {ease: FlxEase.cubeInOut});
			}
		}
	}

	public static function startCutscene():Void
	{
		flem.animation.play('Move ' + emotionNumber);
		FlxTween.tween(flem, {x: FlxG.width / 2 - flem.width / 2}, 3, {onComplete: endCutscene});
	}

	function startEnding():Void
	{
		canMove = false;
		inEnding = true;

		changeEmotion(1);

		flem.flipX = false;
		flem.animation.play('Idle ' + emotionNumber);

		musicDepressed.fadeOut(2, 0);
		musicSad.fadeOut(2, 0);
		musicHappy.fadeOut(2, 0);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.music('flemEnding'), 1);

			flem.animation.play('Move ' + emotionNumber);

			FlxTween.tween(camFollow, {x: camFollow.x + 650}, 15);
			FlxTween.tween(flem, {x: flem.x + 500}, 15, {
				onComplete: function(FlxTwn):Void
				{
					npcGroup.forEach(function(spr:FlxSprite)
					{
						if (spr.ID == NPCs.length - 1)
						{
							spr.animation.play('talk');
						}
					});

					flem.animation.play('Idle ' + emotionNumber);
					FlxTween.tween(camFollow, {y: camFollow.y - 150}, 6);

					var fade:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
					fade.alpha = 0;
					fade.cameras = [camGame];
					fade.scrollFactor.set();
					add(fade);
					FlxTween.tween(fade, {alpha: 1}, 5, {ease: FlxEase.cubeInOut});
				}
			});
		});
	}

	public static function endCutscene(FlxTwn):Void
	{
		canMove = true;
	}
}
