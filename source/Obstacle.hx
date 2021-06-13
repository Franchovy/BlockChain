package;

import Random;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Obstacle extends FlxSprite
{
	static inline var SIZE:Int = 32;

	public static var onTouchedKilledCallback:() -> Void;

	var _activeColour:FlxColor;
	var _isVertical:Bool;
	var _speed:Float;

	public function new(speed:Float, colour:FlxColor)
	{
		super();

		_speed = speed;
		_activeColour = colour;
	}

	public function spawn()
	{
		hasBeenTouchedEnemy = false;

		makeGraphic(SIZE, SIZE, _activeColour);

		_isVertical = Random.bool();
		if (_isVertical)
		{
			// Along top or bottom of the screen
			x = Random.int(1, FlxG.width - SIZE - 1);
			y = Random.bool() ? 1 - SIZE : FlxG.height - 1;
		}
		else
		{
			// Along left or right of the screen
			x = Random.bool() ? 1 - SIZE : FlxG.width - 1;
			y = Random.int(1, FlxG.height - SIZE - 1);
		}
	}

	public function go()
	{
		if (_isVertical)
			velocity.set(0, y > 0 ? -_speed : _speed);
		else
			velocity.set(x > 0 ? -_speed : _speed, 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!isOnScreen())
		{
			if (hasBeenTouchedEnemy)
			{
				onTouchedKilledCallback();
			}

			kill();
		}
	}

	public var hasBeenTouchedEnemy = false;

	public function onTouchEnemy()
	{
		hasBeenTouchedEnemy = true;

		makeGraphic(SIZE, SIZE, FlxColor.fromRGB(150, 150, 255));
	}
}
