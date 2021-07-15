package;

import flixel.util.FlxColor;

class SlowObstacle extends Obstacle
{
	public function new()
	{
		super(100, FlxColor.BLUE);
	}

	override public function spawn()
	{
		super.spawn();
		super.go();
	}
}
