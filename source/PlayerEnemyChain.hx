package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import js.html.Console;

class PlayerEnemyChain extends FlxTypedGroup<FlxSprite>
{
	var PLAYER_SIZE:Int = 30;
	var ENEMY_SIZE:Int = 25;
	var BLOCK_SIZE:Int = 15;

	var hud:HUD;

	public var player:Player;
	public var enemy:Enemy;

	var numBlocks:Int;

	public var blockchain:FlxTypedGroup<ChainBlock>;

	//
	var shiftInput:FlxActionDigital;
	var spaceInput:FlxActionDigital;

	static var BLOCKCHAIN_CAPACITY = 25;
	static var NUM_BLOCKS_START = 7;
	static var PLAYER_START_X = 100;
	static var PLAYER_START_Y = 100;
	static var ENEMY_START_X = 200;
	static var ENEMY_START_Y = 200;

	static var DEFAULT_POWER = 10;
	static var POWER_PER_BLOCK = 5;

	// Power gauge decides a few different variables
	var powerGauge:Float;
	// Effective power ensures a smooth transition to new power value
	var effectivePower:Float;

	public function new(hud:HUD)
	{
		this.hud = hud;

		super();

		player = new Player(PLAYER_START_X, PLAYER_START_Y);
		enemy = new Enemy(ENEMY_START_X, ENEMY_START_Y);

		this.numBlocks = NUM_BLOCKS_START;

		// Instatiate blocks in chain
		blockchain = new FlxTypedGroup<ChainBlock>(BLOCKCHAIN_CAPACITY);
		for (i in 0...BLOCKCHAIN_CAPACITY)
		{
			var block = new ChainBlock();
			block.alive = false;
			blockchain.add(block);
			add(block);
		}

		// Position blocks that make up the chain
		positionBlocks();

		// Add to screen
		player.kill();
		enemy.kill();

		add(player);
		add(enemy);

		// Add space and shift controls
		shiftInput = new FlxActionDigital();
		shiftInput.addKey(SHIFT, PRESSED);

		spaceInput = new FlxActionDigital();
		spaceInput.addKey(SPACE, PRESSED);
	}

	public function setupStart()
	{
		numBlocks = NUM_BLOCKS_START;
		player.reset(PLAYER_START_X, PLAYER_START_Y);
		player.setupStart();
		enemy.kill();
		enemy.reset(ENEMY_START_X, ENEMY_START_Y);

		DEFAULT_POWER = POWER_PER_BLOCK * numBlocks;
		powerGauge = DEFAULT_POWER;

		var blockCount = 0;
		for (block in blockchain)
		{
			block.setupStart();
			blockCount++;

			if (blockCount < numBlocks)
			{
				block.alive = true;
				block.reset(0, 0);
			}
			else
			{
				block.kill();
			}
		}
		positionBlocks();

		FlxG.camera.shake(0.01, 0.2);
	}

	public function death()
	{
		FlxG.camera.shake(0.01, 0.2);

		for (block in blockchain)
		{
			block.disable();
			player.disable();
		}
	}

	private function positionBlocks()
	{
		var i = 1;
		var n = numBlocks + 2;

		blockchain.forEachAlive(function(block)
		{
			var startPosX = player.x + Player.TILE_SIZE / 2 - ChainBlock.TILE_SIZE;
			var startPosY = player.y + Player.TILE_SIZE / 2 - ChainBlock.TILE_SIZE;
			var endPosX = enemy.x + (ChainBlock.TILE_SIZE - Enemy.TILE_SIZE) / 2;
			var endPosY = enemy.y + (ChainBlock.TILE_SIZE - Enemy.TILE_SIZE) / 2;

			var dx = endPosX - startPosX;
			var dy = endPosY - startPosY;

			var targetX = startPosX + dx / n * i + ChainBlock.TILE_SIZE / 2;
			var targetY = startPosY + dy / n * i + ChainBlock.TILE_SIZE / 2;

			var targetPoint = new FlxPoint(targetX, targetY);
			var targetDistance = targetPoint.distanceTo(block.getPosition());

			var extraSpeed = Math.sqrt(i);

			if (targetDistance > 1)
			{
				FlxVelocity.moveTowardsPoint(block, targetPoint, extraSpeed * targetDistance * 10);
			}

			i++;
		});
	}

	public function loseBlock(block:ChainBlock)
	{
		block.disable();

		if (block.alive)
		{
			FlxG.sound.play("assets/sounds/lose_grey.wav");
			FlxG.camera.shake(0.01, 0.02);
		}

		block.alive = false;
		numBlocks = blockchain.countLiving();

		powerGauge -= Math.max(POWER_PER_BLOCK, 0);
		DEFAULT_POWER = numBlocks * POWER_PER_BLOCK;
	}

	public function addBlock()
	{
		var newBlock = blockchain.getFirstDead();

		if (newBlock == null)
		{
			trace("You just too good!");
			return;
		}

		newBlock.setupStart();
		newBlock.alive = true;
		newBlock.reset(player.x, player.y);

		FlxG.sound.play("assets/sounds/new_grey.wav");

		numBlocks = blockchain.countLiving();

		powerGauge += Math.min(3, 100);
		DEFAULT_POWER = numBlocks * POWER_PER_BLOCK;
	}

	var DIST_POW_MULTIPLIER = 3.0;
	var SPEED_POW_MULTIPLIER = 0.01;
	var INITIAL_SPEED = 5;

	var ENEMY_ACCELERATION = 20000;
	var ENEMY_MAX_SPEED = 10000;
	var ENEMY_DRAG = 0.9;

	override public function update(elapsed:Float):Void
	{
		shiftInput.update();
		spaceInput.update();

		super.update(elapsed);

		var enemyPlayerDistanceX = player.x - enemy.x;
		var enemyPlayerDistanceY = player.y - enemy.y;
		var enemyPlayerDistanceVector = new FlxPoint(enemyPlayerDistanceX, enemyPlayerDistanceY);

		var enemyPos = new FlxPoint(enemy.x, enemy.y);
		var playerPos = new FlxPoint(player.x, player.y);

		var angle = playerPos.angleBetween(enemyPos);

		// Speed up spinning if space is pressed
		if (spaceInput.triggered)
		{
			if (powerGauge < DEFAULT_POWER)
			{
				// Low-power power-up speed
				updatePowerGauge(powerGauge + 1);
			}
			else
			{
				// Normal Power up speed
				updatePowerGauge(powerGauge + Math.sqrt(101 - Math.min(100, powerGauge)) / 10);
			}
		}
		else
		{
			if (powerGauge < DEFAULT_POWER)
			{
				// Refill to default speed
				updatePowerGauge(Math.min(powerGauge + 0.5, DEFAULT_POWER));
			}
			else
			{
				// Drain to default speed
				updatePowerGauge(Math.max(powerGauge - Math.sqrt(101 - Math.min(100, powerGauge)) / 5, DEFAULT_POWER));
			}
		}

		// BRAKE ACTION
		if (shiftInput.triggered)
		{
			// Drain speed
			updatePowerGauge(powerGauge - 1);

			if (powerGauge < DEFAULT_POWER)
			{
				angle += 60;
			}
			else
			{
				angle += powerGauge;
			}

			effectivePower = Math.max(powerGauge, 1);
		}
		else
		{
			angle -= (powerGauge * 0.2);

			effectivePower = powerGauge;
		}

		hud.setPower(Math.floor(powerGauge));
		hud.setDefaultPower(DEFAULT_POWER);

		var distanceMultipler = DIST_POW_MULTIPLIER * effectivePower;
		var targetRelativeToPlayer = FlxVelocity.velocityFromAngle(angle, distanceMultipler);
		var targetDistance = targetRelativeToPlayer.distanceTo(new FlxPoint(0, 0));

		FlxVelocity.moveTowardsPoint(enemy, playerPos.addPoint(targetRelativeToPlayer),
			targetDistance * Math.pow(INITIAL_SPEED, SPEED_POW_MULTIPLIER * Math.max(effectivePower, 1)));

		positionBlocks();
	}

	private function updatePowerGauge(power:Float)
	{
		powerGauge = Math.min(100, Math.max(0, power));
	}
}
