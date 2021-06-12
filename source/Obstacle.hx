package;

import Random;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Obstacle extends FlxSprite
{
	static inline var SIZE:Int = 32;
	// TODO: Tie speed to game difficulty
	static inline var SPEED:Float = 200;

	public function new()
	{
		super();

		makeGraphic(SIZE, SIZE, FlxColor.BLUE);
	}

	public function spawn()
	{
		hasBeenTouchedEnemy = false;

		makeGraphic(SIZE, SIZE, FlxColor.BLUE);

		if (Random.bool())
		{
			// Along top or bottom of the screen
			x = Random.int(1, FlxG.width - SIZE - 1);
			y = Random.bool() ? -SIZE : FlxG.height;
			velocity.set(0, y > 0 ? -SPEED : SPEED);
		}
		else
		{
			// Along left or right of the screen
			x = Random.bool() ? -SIZE : FlxG.width;
			y = Random.int(1, FlxG.height - SIZE - 1);
			velocity.set(x > 0 ? -SPEED : SPEED, 0);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!isOnScreen())
			kill();
	}

	public var hasBeenTouchedEnemy = false;

	public function onTouchEnemy()
	{
		hasBeenTouchedEnemy = true;

		makeGraphic(SIZE, SIZE, FlxColor.fromRGB(150, 150, 255));
	}
}
