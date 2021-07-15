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
	var _speedMultiplier:Float = 1.0;

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
			velocity.set(0, y > 0 ? -(_speed * _speedMultiplier) : _speed * _speedMultiplier);
		else
			velocity.set(x > 0 ? -(_speed * _speedMultiplier) : _speed * _speedMultiplier, 0);
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

	public function setSpeedMultiplier(multiplier:Float)
	{
		_speedMultiplier = multiplier;
	}

	public function onTouchEnemy()
	{
		if (!hasBeenTouchedEnemy)
		{
			FlxG.camera.shake(0.01, 0.02);

			if (this is FastObstacle)
			{
				FlxG.sound.play("assets/sounds/hit_yellow.wav");
			}
			else
			{
				FlxG.sound.play("assets/sounds/red-hit-blue.wav");
			}
		}

		hasBeenTouchedEnemy = true;

		makeGraphic(SIZE, SIZE, FlxColor.fromRGB(150, 150, 255));
	}
}
