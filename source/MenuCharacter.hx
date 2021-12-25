package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;

class CharacterSetting
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var scale(default, null):Float;
	public var flipped(default, null):Bool;

	public function new(x:Int = 0, y:Int = 0, scale:Float = 1.0, flipped:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.scale = scale;
		this.flipped = flipped;
	}
}

class MenuCharacter extends FlxSprite
{
	private static var settings:Map<String, CharacterSetting> = [
		'madrat' => new CharacterSetting(0, 13, 0.6, true),
		'ratgod' => new CharacterSetting(100, 170, 1.0, true),
		'heart' => new CharacterSetting(88, 136, 1.0, true),
		'doctor' => new CharacterSetting(-15, 100, 1.25)
	];

	private var flipped:Bool = false;
	// questionable variable name lmfao
	private var goesLeftNRight:Bool = false;
	private var danceLeft:Bool = false;
	private var character:String = '';

	public function new(x:Int, y:Int, scale:Float, flipped:Bool)
	{
		super(x, y);
		this.flipped = flipped;

		antialiasing = FlxG.save.data.antialiasing;

		frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');

		animation.addByPrefix('madrat', 'RAT IDLE', 24, false);
		animation.addByPrefix('ratConfirm', 'RAT BREAKDANCE SELECT', 24, false);
		animation.addByIndices('ratgod-left', 'TUTORIAL', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('ratgod-right', 'TUTORIAL', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.addByIndices('heart-left', 'HEART SPEAKER', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('heart-right', 'HEART SPEAKER', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.addByPrefix('doctor', 'ONE SHOT AT REVENGE', 24, false);

		setGraphicSize(Std.int(width * scale));
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
		var sameCharacter:Bool = character == this.character;
		this.character = character;
		if (character == '')
		{
			visible = false;
			return;
		}
		else
		{
			visible = true;
		}

		if (!sameCharacter)
		{
			bopHead(true);
		}

		var setting:CharacterSetting = settings[character];
		offset.set(setting.x, setting.y);
		setGraphicSize(Std.int(width * setting.scale));
		flipX = setting.flipped != flipped;
	}

	public function bopHead(LastFrame:Bool = false):Void
	{
		if (character == 'ratgod' || character == 'heart')
		{
			danceLeft = !danceLeft;

			if (danceLeft)
				animation.play(character + "-left", true);
			else
				animation.play(character + "-right", true);
		}
		else if (character == '')
		{
			// Don't try to play an animation on an invisible character.
			return;
		}
		else
		{
			// no spooky nor girlfriend so we do da normal animation
			if (animation.name == "ratConfirm")
				return;
			animation.play(character, true);
		}
		if (LastFrame)
		{
			animation.finish();
		}
	}
}
