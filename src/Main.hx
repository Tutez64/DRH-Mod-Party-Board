package mods.party_board;

import mods.api.Context;
import mods.api.Mod;
import mods.api.dungeon.Hero;
import mods.api.dungeon.Player;
import mods.party_board.ui.Board;

/**
 * P in a dungeon shows every player met in it: hero class, level and weapons, with
 * add friend, block and report buttons. Players who left stay listed until the next town.
 */
class Main extends Mod {
	/** P, for party. Tab already moves the focus to the chat. */
	static inline final KEY:UInt = 80;

	var ctx:Context;

	var board:Board;

	/** Row state of the players in `state.players`. */
	var entries:Array<Entry> = [];

	override public function init(ctx:Context):Void {
		this.ctx = ctx;
		board = new Board(act);
		ctx.overlay.addChild(board.root);
		// Works from the first hero to the return to town, end screen included.
		ctx.onKeyDown(function(key:UInt):Bool {
			if (key != KEY || ctx.state.players.length == 0)
				return false;
			toggle();
			return true;
		});
		ctx.onHeroSpawned(function(_:Hero) redraw());
		ctx.onHeroDespawned(function(_:Hero) redraw());
		ctx.onTownEnter(function() {
			entries = [];
			board.root.visible = false;
		});
	}

	/** The players met so far, the local one first, each with its row state. */
	function rows():Array<Entry> {
		var out:Array<Entry> = [];
		for (player in ctx.state.players) {
			var entry = find(player);
			if (entry == null) {
				entry = new Entry(player);
				entries.push(entry);
			}
			if (player.local)
				out.unshift(entry);
			else
				out.push(entry);
		}
		return out;
	}

	function toggle():Void {
		if (board.root.visible) {
			board.root.visible = false;
			return;
		}
		board.root.visible = true;
		redraw();
	}

	function find(player:Player):Null<Entry> {
		for (entry in entries)
			if (entry.player == player)
				return entry;
		return null;
	}

	function redraw():Void {
		if (!board.root.visible)
			return;
		var shown = rows();
		for (entry in shown)
			entry.refresh();
		board.render(shown, ctx.viewWidth, ctx.viewHeight);
	}

	function act(entry:Entry, action:String):Void {
		switch (action) {
			case "friend":
				if (entry.player.addFriend(function() {
					entry.friendState = "Sent";
					redraw();
				})) {
					entry.friendState = "...";
					redraw();
				}
			case "block":
				// The game's popup sits under the overlay.
				board.root.visible = false;
				entry.player.block(function() {
					entry.blocked = true;
					redraw();
				});
			case "report":
				board.root.visible = false;
				entry.player.report();
		}
	}
}
