package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
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
		var dx = enemy.x - player.x;
		var dy = enemy.y - player.y;

		blockchain = new List<ChainBlock>();
		for (i in 0...numBlocks)
		{
			var startPosX = player.x + Player.TILE_SIZE / 2;
			var startPosY = player.y + Player.TILE_SIZE / 2;

			var block = new ChainBlock(startPosX + dx / numBlocks * i, startPosY + dy / numBlocks * i);
			blockchain.add(block);
			add(block);
		}

		add(player);
		add(enemy);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		enemy.velocity.x = player.velocity.x;
		enemy.velocity.y = player.velocity.y;

		for (block in blockchain)
		{
			block.velocity.x = player.velocity.x;
			block.velocity.y = player.velocity.y;
		}
	}
}
