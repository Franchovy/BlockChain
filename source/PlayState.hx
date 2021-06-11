package;

import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

		var text = new flixel.text.FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);

		var player = new Player(10, 10);
		add(player);

		var obstacle = new Obstacle();
		add(obstacle);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
