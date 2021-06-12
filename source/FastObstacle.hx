package;

import flixel.util.FlxColor;

class FastObstacle extends Obstacle
{
	var _elapsedSinceSpawn:Int = 0;

	public function new()
	{
		super(800, FlxColor.ORANGE);
		kill();
	}

	override public function spawn()
	{
		super.spawn();
		_elapsedSinceSpawn++;
		// TODO: Warn the player of the incoming obstacle
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_elapsedSinceSpawn > 0)
		{
			_elapsedSinceSpawn++;
			if (_elapsedSinceSpawn > 200)
			{
				go();
				_elapsedSinceSpawn = 0;
			}
		}
	}
}
