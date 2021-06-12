package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var menu = true;
	var level_clear = false;
	var blockChainText:FlxText;
	var startGameText:FlxText;
	var obstaclesPool:FlxTypedGroup<Obstacle>;

	var player:Player;
	var enemy:Enemy;
	var blockchain:FlxTypedGroup<ChainBlock>;

	var spaceInput:FlxActionDigital;

	override public function create()
	{
		super.create();

		// Add moving blocks

		var poolSize = 30;
		obstaclesPool = new FlxTypedGroup<Obstacle>(poolSize);
		for (i in 0...poolSize)
		{
			var obstacle = new Obstacle();
			obstacle.kill();
			obstaclesPool.add(obstacle);
		}

		// Add menu text

		blockChainText = new flixel.text.FlxText(0, 0, 0, "Block Chain", 64);
		blockChainText.screenCenter();
		add(blockChainText);

		startGameText = new FlxText(0, 0, 0, "Press [Space] to start", 26);
		startGameText.color = FlxColor.fromRGB(200, 200, 200);
		startGameText.screenCenter();
		startGameText.y += 80;
		add(startGameText);

		// Add Space key input

		spaceInput = new FlxActionDigital();
		spaceInput.addKey(SPACE, JUST_PRESSED);
	}

	function startGame()
	{
		if (!menu)
		{
			return;
		}

		menu = false;

		startGameText.kill();
		blockChainText.kill();

		var playerAndEnemy = new PlayerEnemyChain(7);
		add(playerAndEnemy);
	}

	var elapsedSinceLastSpawn:Float = 0;

	override public function update(elapsed:Float)
	{
		spaceInput.update();
		super.update(elapsed);

		if (menu)
		{
			if (spaceInput.triggered)
			{
				startGame();
			}
		}

		if (level_clear)
		{
			return;
		}

		FlxG.collide(blockchain, obstaclesPool);

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
