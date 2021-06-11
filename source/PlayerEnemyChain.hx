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
}
