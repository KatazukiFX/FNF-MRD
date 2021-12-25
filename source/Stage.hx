package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Stage extends MusicBeatState
{
	public var curStage:String = '';
	public var camZoom:Float; // The zoom of the camera to have at the start of the game
	public var hideLastBG:Bool = false; // True = hide last BGs and show ones from slowBacks on certain step, False = Toggle visibility of BGs from SlowBacks on certain step
	// Use visible property to manage if BG would be visible or not at the start of the game
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String,
		Dynamic> = []; // Store BGs here to use them later (for example with slowBacks, using your custom stage event or to adjust position in stage debug menu(press 8 while in PlayState with debug build of the game))
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup/swagBacks and script it in stepHit/beatHit function of this file!!)
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and technically also opponent since Haxe layering moment)
	public var slowBacks:Map<Int,
		Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"

	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// All of the above must be set or used in your stage case code block!!
	public var positions:Map<String, Map<String, Array<Int>>> = [
		// Assign your characters positions on stage here!
		'heartField' => ['bf-madrat' => [920, 400]],
		'cheeseWorld' => ['bf-madrat' => [950, 480]],
		'lab' => ['bf-madrat' => [920, 480], 'gf-heart' => [420, 260], 'gf-ratgod' => [420, 260]],
		'cheeseLab' => ['bf-madrat' => [920, 490], 'gf-heart' => [475, 155], 'gf-ratgod' => [385, 30]],
		'cage' => ['gf-heart' => [350, 120], 'gf-ratgod' => [350, 120]]
	];

	public function new(daStage:String)
	{
		super();
		this.curStage = daStage;
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one
		if (PlayStateChangeables.Optimize)
			return;

		switch (daStage)
		{
			case 'heartField':
				{
					camZoom = 0.9;
					var hallowTex = Paths.getSparrowAtlas('heartField', 'week2');

					var heartField = new FlxSprite(-200, -75);
					heartField.frames = hallowTex;
					heartField.animation.addByPrefix('idle', 'halloweem bg0');
					heartField.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					heartField.animation.play('idle');
					heartField.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['heartField'] = heartField;
					toAdd.push(heartField);
				}
			case 'cheeseWorld':
				{
					camZoom = 0.9;
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('cheeseback', 'tutorial'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var cheeseFront:FlxSprite = new FlxSprite(-825, 280).loadGraphic(Paths.image('cheesefront', 'tutorial'));
					cheeseFront.setGraphicSize(Std.int(cheeseFront.width * 1.1));
					cheeseFront.updateHitbox();
					cheeseFront.antialiasing = FlxG.save.data.antialiasing;
					cheeseFront.active = false;
					swagBacks['cheeseFront'] = cheeseFront;
					toAdd.push(cheeseFront);
				}
			case 'lab':
				{
					camZoom = 0.7;
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('labback', 'week1'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var labFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('labfront', 'week1'));
					labFront.setGraphicSize(Std.int(labFront.width * 1.1));
					labFront.updateHitbox();
					labFront.antialiasing = FlxG.save.data.antialiasing;
					labFront.scrollFactor.set(0.9, 0.9);
					labFront.active = false;
					swagBacks['labFront'] = labFront;
					toAdd.push(labFront);
				}
			case 'cheeseLab':
				{
					camZoom = 0.7;
					var bg:FlxSprite = new FlxSprite(-630, -200).loadGraphic(Paths.image('chlabback', 'week2'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var chLabFront:FlxSprite = new FlxSprite(-1075, -525).loadGraphic(Paths.image('chlabfront', 'week2'));
					chLabFront.setGraphicSize(Std.int(chLabFront.width * 1.3));
					chLabFront.updateHitbox();
					chLabFront.antialiasing = FlxG.save.data.antialiasing;
					chLabFront.scrollFactor.set(0.9, 0.9);
					chLabFront.active = false;
					swagBacks['chLabFront'] = chLabFront;
					toAdd.push(chLabFront);
				}
			default:
				{
					camZoom = 0.9;
					curStage = 'cage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('cageback', 'week1'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var cageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('cagefront', 'week1'));
					cageFront.setGraphicSize(Std.int(cageFront.width * 1.1));
					cageFront.updateHitbox();
					cageFront.antialiasing = FlxG.save.data.antialiasing;
					cageFront.scrollFactor.set(0.9, 0.9);
					cageFront.active = false;
					swagBacks['cageFront'] = cageFront;
					toAdd.push(cageFront);

					var mobBoppers1 = new FlxSprite(1400, 510);
					mobBoppers1.frames = Paths.getSparrowAtlas('mobRats1', 'week1');
					mobBoppers1.animation.addByPrefix('idle', 'RAT MOB1', 24, false);
					mobBoppers1.antialiasing = FlxG.save.data.antialiasing;
					mobBoppers1.setGraphicSize(Std.int(mobBoppers1.width * 1));
					mobBoppers1.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['mobBoppers1'] = mobBoppers1;
						toAdd.push(mobBoppers1);
						animatedBacks.push(mobBoppers1);
					}

					var mobBoppers2 = new FlxSprite(-100, 520);
					mobBoppers2.frames = Paths.getSparrowAtlas('mobRats2', 'week1');
					mobBoppers2.animation.addByPrefix('idle', 'RAT MOB2', 24, false);
					mobBoppers2.antialiasing = FlxG.save.data.antialiasing;
					mobBoppers2.setGraphicSize(Std.int(mobBoppers2.width * 1));
					mobBoppers2.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['mobBoppers2'] = mobBoppers2;
						toAdd.push(mobBoppers2);
						animatedBacks.push(mobBoppers2);
					}

					var mobBopper1 = new FlxSprite(1400, 510);
					mobBopper1.frames = Paths.getSparrowAtlas('mobRat1', 'week1');
					mobBopper1.animation.addByPrefix('idle', 'MOB RAT1', 24, false);
					mobBopper1.antialiasing = FlxG.save.data.antialiasing;
					mobBopper1.setGraphicSize(Std.int(mobBopper1.width * 1));
					mobBopper1.scale.x = 1.39;
					mobBopper1.scale.y = 1.39;
					mobBopper1.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['mobBopper1'] = mobBopper1;
						toAdd.push(mobBopper1);
						animatedBacks.push(mobBopper1);
					}

					var mobBopper2 = new FlxSprite(1700, 530);
					mobBopper2.frames = Paths.getSparrowAtlas('mobRat2', 'week1');
					mobBopper2.animation.addByPrefix('idle', 'MOB RAT 2', 24, false);
					mobBopper2.antialiasing = FlxG.save.data.antialiasing;
					mobBopper2.setGraphicSize(Std.int(mobBopper2.width * 1));
					mobBopper2.scale.x = 1.19;
					mobBopper2.scale.y = 1.19;
					mobBopper2.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['mobBopper2'] = mobBopper2;
						toAdd.push(mobBopper2);
						animatedBacks.push(mobBopper2);
					}

					var mobBopper3 = new FlxSprite(150, 530);
					mobBopper3.frames = Paths.getSparrowAtlas('mobRat3', 'week1');
					mobBopper3.animation.addByPrefix('idle', 'MOB RAT3', 24, false);
					mobBopper3.antialiasing = FlxG.save.data.antialiasing;
					mobBopper3.setGraphicSize(Std.int(mobBopper3.width * 1));
					mobBopper3.scale.x = 1.39;
					mobBopper3.scale.y = 1.39;
					mobBopper3.flipX = true;
					mobBopper3.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['mobBopper3'] = mobBopper3;
						toAdd.push(mobBopper3);
						animatedBacks.push(mobBopper3);
					}

					var mobBopper4 = new FlxSprite(1200, 530);
					mobBopper4.frames = Paths.getSparrowAtlas('mobRat4', 'week1');
					mobBopper4.animation.addByPrefix('idle', 'MOB RAT 4', 24, false);
					mobBopper4.antialiasing = FlxG.save.data.antialiasing;
					mobBopper4.setGraphicSize(Std.int(mobBopper4.width * 1));
					mobBopper4.scale.x = 1.19;
					mobBopper4.scale.y = 1.19;
					mobBopper4.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['mobBopper4'] = mobBopper4;
						toAdd.push(mobBopper4);
						animatedBacks.push(mobBopper4);
					}
				}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function stepHit()
	{
		super.stepHit();

		if (!PlayStateChangeables.Optimize)
		{
			var array = slowBacks[curStep];
			if (array != null && array.length > 0)
			{
				if (hideLastBG)
				{
					for (bg in swagBacks)
					{
						if (!array.contains(bg))
						{
							var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration, {
								onComplete: function(tween:FlxTween):Void
								{
									bg.visible = false;
								}
							});
						}
					}
					for (bg in array)
					{
						bg.visible = true;
						FlxTween.tween(bg, {alpha: 1}, tweenDuration);
					}
				}
				else
				{
					for (bg in array)
						bg.visible = !bg.visible;
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.save.data.distractions && animatedBacks.length > 0)
		{
			for (bg in animatedBacks)
				bg.animation.play('idle', true);
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'heartField':
					if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
					{
						if (FlxG.save.data.distractions)
						{
							lightningStrikeShit();
						}
					}
			}
		}
	}

	// Variables and Functions for Stages
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var curLight:Int = 0;

	function lightningStrikeShit():Void
	{
		swagBacks['heartField'].animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);
	}
}
