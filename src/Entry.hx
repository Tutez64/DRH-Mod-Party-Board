package mods.party_board;

import mods.api.dungeon.Player;
import mods.api.account.Weapon;

/** One player's row. Keeps what their hero last showed, so a player who left still shows it. */
class Entry {
	public var player(default, null):Player;

	public var className(default, null):String = "";

	public var level(default, null):UInt = 0;

	public var weapons(default, null):Array<Weapon> = [];

	public var present(get, never):Bool;

	public var friendState:String = "";

	public var blocked:Bool = false;

	public function new(player:Player) {
		this.player = player;
		refresh();
	}

	function get_present():Bool {
		return player.hero != null;
	}

	/** Reads the player's hero. Does nothing while they have none. */
	public function refresh():Void {
		var hero = player.hero;
		if (hero == null || hero.classId == 0)
			return;
		className = hero.className;
		level = hero.level;
		weapons = hero.weapons;
	}
}
