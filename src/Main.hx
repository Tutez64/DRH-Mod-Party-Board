package mods.party_board;

import mods.api.Context;
import mods.api.Mod;
import mods.api.dungeon.Hero;
import mods.api.dungeon.Player;
import mods.party_board.ui.Board;

/**
 * Its key in a dungeon shows every player met in it: hero class, level and weapons, with
 * add friend, block and report buttons. Players who left stay listed until the dungeon is left.
 */
class Main extends Mod {
	/** P, for party, until the player picks another. Tab already moves the focus to the chat. */
	static inline final KEY:UInt = 80;

	var ctx:Context;

	var board:Board;

	/** Row state of the players in `state.players`. */
	var entries:Array<Entry> = [];

	override public function init(ctx:Context):Void {
		this.ctx = ctx;
		board = new Board(act);
		ctx.overlay.addChild(board.root);
		// Works from the first hero to the end of the dungeon, end screen included.
		ctx.keys.action("toggle", "Show or hide", "Shows or hides the players met in the dungeon.", KEY).onPress(function() {
			if (ctx.state.players.length > 0)
				toggle();
		});
		// Read while the board is closed too: it then opens on players who already left.
		ctx.onHeroSpawned(function(_:Hero) redraw());
		ctx.onHeroDespawned(function(_:Hero) redraw());
		// A dungeon left empties the players: the board closes at the first of these that follows.
		ctx.onFloorEnter(function(_) redraw());
		ctx.onFloorExit(function(_) redraw());
		ctx.onTownEnter(function() redraw());
	}

	/** The players met so far, the local one first, each with its row state. Those of a dungeon left are dropped. */
	function rows():Array<Entry> {
		var out:Array<Entry> = [];
		for (player in ctx.state.players) {
			var entry = find(player);
			if (entry == null)
				entry = new Entry(player);
			if (player.local)
				out.unshift(entry);
			else
				out.push(entry);
		}
		entries = out;
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

	/** Reads the heroes, and draws the board if it is open. It closes once the dungeon is left, for the town or for another one. */
	function redraw():Void {
		var shown = rows();
		if (shown.length == 0)
			board.root.visible = false;
		for (entry in shown)
			entry.refresh();
		if (board.root.visible)
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
