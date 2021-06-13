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
import flixel.system.FlxAssets;
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
	var obstaclesPool:FlxTypedGroup<SlowObstacle>;
	var walls:FlxGroup;
	var fastObstacle:FastObstacle;

	var playerAndEnemy:PlayerEnemyChain;
	var hud:HUD;
	// Main Menu Text
	var blockChainText:FlxText;
	var startGameText:FlxText;
	var controlsText:FlxText;
	var explainText1:FlxText;
	var explainText2:FlxText;
	var explainText3:FlxText;
	var explainText4:FlxText;
	// Game Over Text
	var gameOverText:FlxText;
	var tryAgainText:FlxText;

	var spaceInput:FlxActionDigital;

	override public function create()
	{
		super.create();

		// Play music
		FlxG.sound.playMusic(FlxAssets.getSound("assets/music/menu_music"));

		// Add moving blocks

		var poolSize = 30;
		obstaclesPool = new FlxTypedGroup<SlowObstacle>(poolSize);
		for (_ in 0...poolSize)
		{
			var obstacle = new SlowObstacle();
			obstacle.kill();
			obstaclesPool.add(obstacle);
		}

		//

		walls = FlxCollision.createCameraWall(FlxG.camera, 1);
		fastObstacle = new FastObstacle();

		// Instantiate Player/Enemy and HUD

		hud = new HUD();
		playerAndEnemy = new PlayerEnemyChain(hud);

		// Set callback to player to get more blocks

		Obstacle.onTouchedKilledCallback = () ->
		{
			playerAndEnemy.addBlock();
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

		controlsText = new FlxText(0, 0, 0, "[W,A,S,D] to move. [Space] to power up. [Shift] in emergency.", 16);
		controlsText.color = FlxColor.fromRGB(230, 230, 230);
		controlsText.screenCenter();
		controlsText.y -= 160;
		add(controlsText);

		var explainFontSize = 19;
		explainText1 = new FlxText(0, 0, 0, "Don't let ", explainFontSize);
		explainText1.color = FlxColor.fromRGB(125, 125, 125);
		add(explainText1);
		explainText2 = new FlxText(0, 0, 0, "White", explainFontSize);
		explainText2.color = FlxColor.fromRGB(255, 255, 255);
		add(explainText2);
		explainText3 = new FlxText(0, 0, 0, " touch the ", explainFontSize);
		explainText3.color = FlxColor.fromRGB(125, 125, 125);
		add(explainText3);
		explainText4 = new FlxText(0, 0, 0, "Blue", explainFontSize);
		explainText4.color = FlxColor.BLUE;
		add(explainText4);

		var totalWidth = explainText1.width + explainText2.width + explainText3.width + explainText4.width;
		explainText1.x = (FlxG.width - totalWidth) / 2;
		explainText2.x = explainText1.x + explainText1.width;
		explainText3.x = explainText2.x + explainText2.width;
		explainText4.x = explainText3.x + explainText3.width;
		explainText1.y = controlsText.y + 30;
		explainText2.y = controlsText.y + 30;
		explainText3.y = controlsText.y + 30;
		explainText4.y = controlsText.y + 30;

		gameOverText = new flixel.text.FlxText(0, 0, 0, "Game Over", 64);

		tryAgainText = new FlxText(0, 0, 0, "Press [Space] to try again", 22);
		tryAgainText.color = FlxColor.fromRGB(200, 200, 200);

		// Add Space key input

		spaceInput = new FlxActionDigital();
		spaceInput.addKey(SPACE, JUST_PRESSED);
	}

	function startGame()
	{
		if (!menu && !game_over)
		{
			return;
		}

		menu = false;
		game_over = false;

		for (obstacle in obstaclesPool)
		{
			obstacle.kill();
		}

		startGameText.kill();
		blockChainText.kill();

		gameOverText.kill();
		tryAgainText.kill();

		controlsText.alpha = 0.0;
		explainText1.alpha = 0.0;
		explainText2.alpha = 0.0;
		explainText3.alpha = 0.0;
		explainText4.alpha = 0.0;

		// Add HUD

		hud.recycle();

		add(hud);
		add(playerAndEnemy);

		playerAndEnemy.setupStart();

		// FlxG.sound.music.kill();
		FlxG.sound.playMusic(FlxAssets.getSound("assets/music/game_music"));
	}

	function setGameOver()
	{
		if (game_over)
		{
			return;
		}

		FlxG.sound.playMusic(FlxAssets.getSound("assets/music/menu_music"));

		game_over = true;

		controlsText.alpha = 1.0;
		explainText1.alpha = 1.0;
		explainText2.alpha = 1.0;
		explainText3.alpha = 1.0;
		explainText4.alpha = 1.0;

		gameOverText.reset(0, 0);
		tryAgainText.reset(0, 0);
		gameOverText.screenCenter();
		tryAgainText.screenCenter();
		tryAgainText.y += 80;

		add(gameOverText);
		add(tryAgainText);
	}

	var elapsedSinceLastSpawn:Float = 0;

	override public function update(elapsed:Float)
	{
		spaceInput.update();
		super.update(elapsed);

		if (menu || game_over)
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
					playerAndEnemy.death();

					setGameOver();
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
			// 1 out of 10 chance of that block being a fast moving block.
			if (!fastObstacle.alive && Random.float(0, 10.0) > 9)
			{
				fastObstacle.revive();
				add(fastObstacle);
				fastObstacle.spawn();
			}
			else
			{
				var obstacle = obstaclesPool.recycle(SlowObstacle);
				add(obstacle);
				obstacle.spawn();
			}
			elapsedSinceLastSpawn = 0;
		}
		else
		{
			elapsedSinceLastSpawn += elapsed;
		}
	}
}
