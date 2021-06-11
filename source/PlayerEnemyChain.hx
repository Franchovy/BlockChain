package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.util.FlxColor;

class PlayerEnemyChain extends FlxTypedGroup<FlxSprite>
{
	var player:Player;
	var enemy:Enemy;

	public function new()
	{
		super();

		player = new Player(100, 100);
		enemy = new Enemy(200, 200);

		add(player);
		add(enemy);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// if player is moving away from enemy
		// - drag enemy with player, matching velocity at drag angle

		// shorten distance between player and enemy over time
		var enemyMoveX = player.x - enemy.x;
		var enemyMoveY = player.y - enemy.y;
		enemy.velocity.x = enemyMoveX;
		enemy.velocity.y = enemyMoveY;
	}
}
