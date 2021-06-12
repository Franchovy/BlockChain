package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var menu = true;
	var game_over = false;
	var level_clear = false;
	var blockChainText:FlxText;
	var startGameText:FlxText;
	var obstaclesPool:FlxTypedGroup<Obstacle>;
	var walls:FlxGroup;

	var playerAndEnemy:PlayerEnemyChain;
	var hud:HUD;

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

		walls = FlxCollision.createCameraWall(FlxG.camera, 1);

		// Instantiate Player/Enemy and HUD

		hud = new HUD();
		playerAndEnemy = new PlayerEnemyChain(7, hud);

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

		// Add HUD

		add(hud);

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

		// If enemy is nearby to an obstacle, accelerate towards it
		obstaclesPool.forEachAlive(function(obstacle)
		{
			if (FlxG.overlap(obstacle, playerAndEnemy.enemy))
			{
				// Touch happened
				obstacle.onTouchEnemy();
			}
			else if (!obstacle.hasBeenTouchedEnemy)
			{
				var obstaclePos = obstacle.getPosition();
				if (obstaclePos.distanceTo(playerAndEnemy.enemy.getPosition()) < 10)
				{
					FlxVelocity.accelerateTowardsObject(playerAndEnemy.enemy, obstacle, 100000, 100000);
				}
			}

			if (!obstacle.hasBeenTouchedEnemy)
			{
				if (FlxG.overlap(obstacle, playerAndEnemy.player))
				{
					game_over = true;
					playerAndEnemy.kill();
					// TODO: Implement try again after game over
				}
				for (block in playerAndEnemy.blockchain)
				{
					if (FlxG.overlap(obstacle, block))
					{
						playerAndEnemy.loseBlock(block);
						block.disable();
					}
				}
			}
		});

		if (level_clear || game_over)
		{
			return;
		}

		FlxG.collide(obstaclesPool, playerAndEnemy);
		FlxG.collide(walls, playerAndEnemy.player);

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
