package;

import flixel.FlxG;
import flixel.FlxObject;
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
	var game_over = false;
	var level_clear = false;
	var blockChainText:FlxText;
	var startGameText:FlxText;
	var obstaclesPool:FlxTypedGroup<Obstacle>;

	var playerAndEnemy:PlayerEnemyChain;

	var spaceInput:FlxActionDigital;

	override public function create()
	{
		super.create();

		// Add moving blocks

		var poolSize = 30;
		obstaclesPool = new FlxTypedGroup<Obstacle>(poolSize);
		for (_ in 0...poolSize)
		{
			var obstacle = new Obstacle();
			obstacle.kill();
			obstaclesPool.add(obstacle);
		}

		playerAndEnemy = new PlayerEnemyChain(7);

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

		if (FlxG.overlap(obstaclesPool, playerAndEnemy.player))
		{
			game_over = true;
			playerAndEnemy.kill();
			// TODO: Implement try again after game over
		}

		if (level_clear || game_over)
		{
			return;
		}

		FlxG.collide(obstaclesPool, playerAndEnemy);

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
