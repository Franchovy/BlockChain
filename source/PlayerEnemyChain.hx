package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
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

	var player:Player;
	var enemy:Enemy;

	var numBlocks:Int;
	var blockchain:List<ChainBlock>;

	public function new(numBlocks:Int)
	{
		super();

		player = new Player(100, 100);
		enemy = new Enemy(200, 200);

		this.numBlocks = numBlocks;

		// Instatiate blocks in chain
		blockchain = new List<ChainBlock>();
		for (i in 0...numBlocks)
		{
			var startPosX = player.x + Player.TILE_SIZE / 2;
			var startPosY = player.y + Player.TILE_SIZE / 2;

			var block = new ChainBlock();
			blockchain.add(block);
			add(block);
		}

		positionBlocks();

		add(player);
		add(enemy);
	}

	private function positionBlocks()
	{
		var i = 1;
		var n = numBlocks + 1;

		for (block in blockchain)
		{
			var startPosX = player.x + Player.TILE_SIZE / 2 - ChainBlock.TILE_SIZE;
			var startPosY = player.y + Player.TILE_SIZE / 2 - ChainBlock.TILE_SIZE;
			var endPosX = enemy.x + (ChainBlock.TILE_SIZE - Enemy.TILE_SIZE) / 2;
			var endPosY = enemy.y + (ChainBlock.TILE_SIZE - Enemy.TILE_SIZE) / 2;

			var dx = endPosX - startPosX;
			var dy = endPosY - startPosY;

			block.x = startPosX + dx / n * i + ChainBlock.TILE_SIZE / 2;
			block.y = startPosY + dy / n * i + ChainBlock.TILE_SIZE / 2;

			i++;
		}
	}

	var chainDistance = 150;
	var ENEMY_ACCELERATION = 20000;
	var ENEMY_MAX_SPEED = 10000;
	var ENEMY_DRAG = 0.9;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// var playerVelocityAngle = Math.atan2(player.velocity.y, player.velocity.x);
		// trace("Player velocity angle: "); // √
		// trace(playerVelocityAngle / (Math.PI * 2) * 360);
		// var enemyToPlayerAngle = Math.PI - Math.atan2(enemy.y - player.y, enemy.x - player.x);
		// trace("Enemy to player angle: "); // √
		// trace(enemyToPlayerAngle / (Math.PI * 2) * 360);

		var enemyPlayerDistanceX = player.x - enemy.x;
		var enemyPlayerDistanceY = player.y - enemy.y;
		var enemyPlayerDistanceVector = new FlxPoint(enemyPlayerDistanceX, enemyPlayerDistanceY);

		if (cast(enemyPlayerDistanceVector, FlxVector).length > chainDistance)
		{
			// Accelerate
			FlxVelocity.accelerateTowardsObject(enemy, player, ENEMY_ACCELERATION, ENEMY_MAX_SPEED);
			trace("Accelerating");
		}
		else
		{
			enemy.acceleration.x = -enemy.acceleration.x / 2;
			enemy.acceleration.y = -enemy.acceleration.y / 2;
			enemy.velocity.x = enemy.velocity.x * ENEMY_DRAG;
			enemy.velocity.y = enemy.velocity.y * ENEMY_DRAG;

			trace("Slowing down");
		}

		positionBlocks();
	}
}
