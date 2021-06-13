package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var blockCounter:FlxSprite;

	var powerBar:FlxSprite;
	var powerBarFill:FlxSprite;
	var powerBarCounter:FlxText;

	public function new()
	{
		super();

		powerBar = new FlxSprite().makeGraphic(170, 26, FlxColor.WHITE);
		powerBar.drawRect(2, 2, 166, 22, FlxColor.BLACK);
		powerBar.x = 15;
		powerBar.y = 15;

		powerBarFill = new FlxSprite().makeGraphic(160, 20, FlxColor.fromRGB(0, 255, 0));
		powerBarFill.x = 15 + 5;
		powerBarFill.y = 15 + 3;

		add(powerBar);
		add(powerBarFill);

		powerBarCounter = new FlxText(5, 5, 50, null, 20);
		add(powerBarCounter);
	}

	public function setNumBlocks(power:Int, numBlocks:Int) {}

	public function setPower(power:Int)
	{
		powerBarCounter.text = Std.string(power);

		powerBarFill.fill(FlxColor.TRANSPARENT);

		var colorValue = Math.floor(power / 100 * 255);
		powerBarFill.drawRect(0, 0, power / 100 * 160, 20, FlxColor.fromRGB(colorValue, colorValue, 0));
	}

	var defaultPower:Int;

	public function setDefaultPower(defaultPower:Int) {}
}
