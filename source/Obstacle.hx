package;

import Random;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Obstacle extends FlxSprite
{
	static inline var SIZE:Int = 32;
	static inline var SPEED:Float = 200;

	public function new()
	{
		super();

		makeGraphic(SIZE, SIZE, FlxColor.BLUE);
	}

	public function spawn()
	{
		var isVertical:Bool = Random.bool();

		if (isVertical)
		{
			// Along top or bottom of the screen
			x = Random.int(0, FlxG.width - SIZE);
			y = Random.bool() ? -SIZE : FlxG.height;
		}
		else
		{
			// Along left or right of the screen
			x = Random.bool() ? -SIZE : FlxG.width;
			y = Random.int(0, FlxG.height - SIZE);
		}

		if (isVertical)
			velocity.y = y > 0 ? -SPEED : SPEED;
		else
			velocity.x = x > 0 ? -SPEED : SPEED;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		trace("Velocity X:");
		trace(velocity.x);
		trace("Velocity Y:");
		trace(velocity.y);

		if (velocity.x > 0 && x > FlxG.width)
		{
			kill();
			trace("Kill right");
		}
		else if (velocity.x < 0 && x < SIZE)
		{
			kill();
			trace("Kill left");
		}
		else if (velocity.y > 0 && y > FlxG.height)
		{
			kill();
			trace("Kill bottom");
		}
		else if (velocity.y < 0 && y < SIZE)
		{
			kill();
			trace("Kill top");
		}
	}
}
