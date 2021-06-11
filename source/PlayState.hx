package;

import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

		var text = new flixel.text.FlxText(0, 0, 0, "Block Chain", 64);
		text.screenCenter();
		add(text);

		var playerAndEnemy = new PlayerEnemyChain();
		add(playerAndEnemy);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
