package mods.party_board.ui;

import mods.party_board.Entry;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

/** The table itself: one row per player, rebuilt whenever something changes. */
class Board {
	static inline final WIDTH:Float = 720;

	static inline final HEADER:Float = 34;

	static inline final ROW:Float = 64;

	static inline final PORTRAIT:Float = 52;

	static inline final SLOT:Float = 56;

	static inline final BUTTON_WIDTH:Float = 76;

	public var root(default, null):Sprite;

	/** Asked by a row button: the entry and which action. */
	var onAction:Entry->String->Void;

	public function new(onAction:Entry->String->Void) {
		this.onAction = onAction;
		root = new Sprite();
		root.visible = false;
		// Clicks on the board are not clicks on the dungeon.
		root.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent) event.stopImmediatePropagation());
	}

	public function render(entries:Array<Entry>, viewWidth:Float, viewHeight:Float):Void {
		while (root.numChildren > 0)
			root.removeChildAt(0);
		var height = HEADER + ROW * Math.max(1, entries.length) + 8;
		root.x = Math.round((viewWidth - WIDTH) / 2);
		root.y = Math.round(Math.max(20, (viewHeight - height) / 3));
		root.graphics.clear();
		root.graphics.lineStyle(1, 0x6B83A8);
		root.graphics.beginFill(0x0E1522, 0.9);
		root.graphics.drawRoundRect(0, 0, WIDTH, height, 10, 10);
		root.graphics.endFill();

		text("PARTY", 12, 8, 200, 15, 0xF2D27A, true);
		text("P to close", WIDTH - 132, 10, 120, 12, 0x8894A8, false, true);
		if (entries.length == 0)
			text("Nobody here yet.", 12, HEADER + 8, 300, 13, 0xB0B8C8);

		var y = HEADER;
		for (entry in entries) {
			row(entry, y);
			y += ROW;
		}
	}

	function row(entry:Entry, y:Float):Void {
		root.graphics.lineStyle(1, 0x26324A);
		root.graphics.moveTo(8, y);
		root.graphics.lineTo(WIDTH - 8, y);

		var dim = !entry.present;
		var you = entry.player.local;

		var portrait = entry.player.createPortrait(PORTRAIT);
		portrait.x = 12;
		portrait.y = y + (ROW - PORTRAIT) / 2;
		portrait.alpha = dim ? 0.4 : 1;
		root.addChild(portrait);

		var nameColor = you ? 0x9FE0A0 : dim ? 0x7A7F8A : 0xFFFFFF;
		text(entry.player.name + (you ? "  (you)" : ""), 72, y + 12, 184, 14, nameColor, true);
		var sub = entry.className + "  ·  Lv " + entry.level;
		if (dim)
			sub += "  ·  left";
		text(sub, 72, y + 34, 184, 12, dim ? 0x6A6F7A : 0xB0B8C8);

		// Three slots, as the end screen: the icon shows the game's tooltip, power included, on hover.
		var slotsX = 262;
		for (slot in 0...3) {
			var x = slotsX + slot * (SLOT + 8);
			root.graphics.lineStyle(1, 0x3A4A66);
			root.graphics.beginFill(0x182235, 0.95);
			root.graphics.drawRoundRect(x, y + (ROW - SLOT) / 2, SLOT, SLOT, 6, 6);
			root.graphics.endFill();
		}
		for (weapon in entry.weapons) {
			if (weapon.slot < 0 || weapon.slot > 2)
				continue;
			var x = slotsX + weapon.slot * (SLOT + 8);
			var icon = weapon.createIcon(SLOT - 2);
			icon.x = x + 1;
			icon.y = y + (ROW - SLOT) / 2 + 1;
			icon.alpha = dim ? 0.4 : 1;
			root.addChild(icon);
		}

		if (you)
			return;
		var x = WIDTH - 12 - BUTTON_WIDTH * 3 - 8;
		var friend = button("Add friend", x, y, function() onAction(entry, "friend"));
		if (entry.player.isFriend)
			friend.disable("Friend");
		else if (entry.friendState != "")
			friend.disable(entry.friendState);
		var block = button("Block", x + BUTTON_WIDTH + 4, y, function() onAction(entry, "block"));
		if (entry.blocked)
			block.disable("Blocked");
		// Stays active: a player can be reported again for another reason.
		button("Report", x + (BUTTON_WIDTH + 4) * 2, y, function() onAction(entry, "report"));
	}

	function button(label:String, x:Float, y:Float, action:Void->Void):Button {
		var made = new Button(label, BUTTON_WIDTH, 24, action);
		made.root.x = x;
		made.root.y = y + (ROW - 24) / 2;
		root.addChild(made.root);
		return made;
	}

	function text(value:String, x:Float, y:Float, width:Float, size:Int, color:Int, bold:Bool = false, right:Bool = false):TextField {
		var field = new TextField();
		var format = new TextFormat("_sans", size, color, bold);
		if (right)
			format.align = openfl.text.TextFormatAlign.RIGHT;
		field.defaultTextFormat = format;
		field.selectable = false;
		field.mouseEnabled = false;
		field.width = width;
		field.height = size + 8;
		field.x = x;
		field.y = y;
		field.text = value;
		root.addChild(field);
		return field;
	}
}
