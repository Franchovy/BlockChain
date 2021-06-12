package;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	var obstaclesPool:FlxTypedGroup<Obstacle>;

	var player:Player;
	var enemy:Enemy;
	var blockchain:FlxTypedGroup<ChainBlock>;

	override public function create()
	{
		super.create();

		var text = new flixel.text.FlxText(0, 0, 0, "Block Chain", 64);
		text.screenCenter();
		add(text);

		var playerAndEnemy = new PlayerEnemyChain(7);
		add(playerAndEnemy);

		var poolSize = 30;
		obstaclesPool = new FlxTypedGroup<Obstacle>(poolSize);
		for (i in 0...poolSize)
		{
			var obstacle = new Obstacle();
			obstacle.kill();
			obstaclesPool.add(obstacle);
		}
	}

	var elapsedSinceLastSpawn:Float = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// 1 out of 10 chance of spawning block per second.
		if (Random.float(0, 10.0) * elapsedSinceLastSpawn > 9)
		{
			var obstacle = obstaclesPool.recycle(Obstacle);

			add(obstacle);
			obstacle.spawn();

			elapsedSinceLastSpawn = 0;
		}
		else
		{
			elapsedSinceLastSpawn += elapsed;
		}
	}
}
