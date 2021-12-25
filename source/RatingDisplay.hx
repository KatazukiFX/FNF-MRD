package;

import flixel.FlxG;
import flixel.FlxSprite;

class RatingDisplay extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		antialiasing = FlxG.save.data.antialiasing;

		loadGraphic(Paths.image('ratings'), true, 330, 120);
		animation.add("SSS+", [0], 0, false);
		animation.add("SSS", [1], 0, false);
		animation.add("SS+", [2], 0, false);
		animation.add("SS", [3], 0, false);
		animation.add("S+", [4], 0, false);
		animation.add("S", [5], 0, false);
		animation.add("A+", [6], 0, false);
		animation.add("A", [7], 0, false);
		animation.add("B+", [8], 0, false);
		animation.add("B", [9], 0, false);
		animation.add("C+", [10], 0, false);
		animation.add("C", [11], 0, false);
		animation.add("C-", [12], 0, false);
		animation.add("none", [13], 0, false);

		scale.x = 0.5;
		scale.y = 0.5;
	}

	public function displayRating(rating:String = "")
	{
		animation.play(rating, false);
	}
}
