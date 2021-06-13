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

	var shiftInput:FlxActionDigital;
	var spaceInput:FlxActionDigital;

	static var BLOCKCHAIN_CAPACITY = 25;
	static var NUM_BLOCKS_START = 7;
	static var PLAYER_START_X = 100;
	static var PLAYER_START_Y = 100;
	static var ENEMY_START_X = 200;
	static var ENEMY_START_Y = 200;

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

			var extraSpeedForBlocksNearPlayerOrEnemy = cast(Math.min(n - i, i), Int);
			var extraSpeed = extraSpeedForBlocksNearPlayerOrEnemy < 3 ? [3.0, 2.0, 1.5,][extraSpeedForBlocksNearPlayerOrEnemy] : 1.0;

			if (targetDistance > 1)
			{
				FlxVelocity.moveTowardsPoint(block, targetPoint, extraSpeed * Math.pow(targetDistance, Math.max(Math.sqrt(power), 1.5)));
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
	}

	var chainDistance = 250;
	var ENEMY_ACCELERATION = 20000;
	var ENEMY_MAX_SPEED = 10000;
	var ENEMY_DRAG = 0.9;
	var MAX_POWER = 4.0;
	var power = 0.0;

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
			if (power == 0)
			{
				power = 0.2;
			}
			else if (power < MAX_POWER)
			{
				power *= 1.1;
			}

			angle -= 15;
		}
		else
		{
			power = 0.0;
		}

		hud.setPower(Math.floor(10 * Math.pow(1.5, power)));

		var extraSpeed = Math.pow(1.1, power);

		// bring chain in if shift is pressed
		if (shiftInput.triggered)
		{
			chainDistance = 150;

			angle += 75;
			extraSpeed += 2.0;
		}
		else
		{
			chainDistance = blockchain.length * 30;
		}

		var targetRelativeToPlayer = FlxVelocity.velocityFromAngle(angle, chainDistance * Math.pow(1.1, power));

		var targetDistance = targetRelativeToPlayer.distanceTo(new FlxPoint(0, 0));

		FlxVelocity.moveTowardsPoint(enemy, playerPos.addPoint(targetRelativeToPlayer), targetDistance * extraSpeed);

		positionBlocks();
	}
}
