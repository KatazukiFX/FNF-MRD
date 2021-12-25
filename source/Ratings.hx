import flixel.FlxG;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = "N/A";
		if (FlxG.save.data.botplay && !PlayState.loadRep)
			ranking = "BotPlay";

		if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (PlayState.misses == 0) // Regular FC
			ranking = "(FC)";
		else if (PlayState.misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.990, // SSS+
			accuracy >= 99.950, // SSS
			accuracy >= 99.90, // SS+
			accuracy >= 99.50, // SS
			accuracy >= 99, // S+
			accuracy >= 97.50, // S
			accuracy >= 95, // A+
			accuracy >= 90, // A
			accuracy >= 85, // B+
			accuracy >= 80, // B
			accuracy >= 75, // C+
			accuracy >= 70, // C
			accuracy < 70 // C-
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " SSS+";
					case 1:
						ranking += " SSS";
					case 2:
						ranking += " SS+";
					case 3:
						ranking += " SS";
					case 4:
						ranking += " S+";
					case 5:
						ranking += " S";
					case 6:
						ranking += " A+";
					case 7:
						ranking += " A";
					case 8:
						ranking += " B+";
					case 9:
						ranking += " B";
					case 10:
						ranking += " C+";
					case 11:
						ranking += " C";
					case 12:
						ranking += " C-";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";
		else if (FlxG.save.data.botplay && !PlayState.loadRep)
			ranking = "BotPlay";

		return ranking;
	}

	public static var timingWindows = [];

	public static function judgeNote(noteDiff:Float)
	{
		var diff = Math.abs(noteDiff);
		for (index in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
		{
			var time = timingWindows[index];
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
			if (diff < time && diff >= nextTime)
			{
				switch (index)
				{
					case 0: // shit
						return "shit";
					case 1: // bad
						if (noteDiff < 0)
							return "early";
						else
							return "late";
					case 2: // good
						return "good";
					case 3: // sick
						return "sick";
				}
			}
		}
		return "good";
	}

	public static function CalculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		return (FlxG.save.data.npsDisplay ? // NPS Toggle
			"NPS: "
			+ nps
			+ " (Max "
			+ maxNPS
			+ ")"
			+ (!PlayStateChangeables.botPlay || PlayState.loadRep ? " | " : "") : "") + // 	NPS
			(!PlayStateChangeables.botPlay
				|| PlayState.loadRep ? "Score:" + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) + // Score
					(FlxG.save.data.accuracyDisplay ? // Accuracy Toggle
						" | Combo Breaks:"
						+ PlayState.misses
						+ // 	Misses/Combo Breaks
						" | Accuracy:"
						+ (PlayStateChangeables.botPlay && !PlayState.loadRep ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %")
						+ // 	Accuracy
						" | "
						+ GenerateLetterRank(accuracy) : "") : ""); // 	Letter Rank
	}
}
