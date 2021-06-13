package;

import flixel.FlxG;
import flixel.util.FlxColor;

class FastObstacle extends Obstacle
{
	var _elapsedSinceSpawn:Int = 0;

	public function new()
	{
		super(1000, FlxColor.ORANGE);
		kill();
	}

	override public function spawn()
	{
		super.spawn();
		_elapsedSinceSpawn++;
		// Peak out to warn the player of the incoming obstacle
		if (_isVertical)
			velocity.set(0, y > 0 ? -5 : 5);
		else
			velocity.set(x > 0 ? -5 : 5, 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.sound.play("assets/sounds/gold_launch.wav");

		if (_elapsedSinceSpawn > 0 && ++_elapsedSinceSpawn > 100)
		{
			go();
			_elapsedSinceSpawn = 0;
		}
	}
}
