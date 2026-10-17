package mods.party_board.ui;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/** A flat text button. Swallows its mouse down so the hero does not attack through it. */
class Button {
	public var root(default, null):Sprite;

	var label:TextField;

	var width:Float;

	var height:Float;

	var action:Void->Void;

	var enabled:Bool = true;

	var over:Bool = false;

	public function new(text:String, width:Float, height:Float, action:Void->Void) {
		this.width = width;
		this.height = height;
		this.action = action;
		root = new Sprite();
		root.buttonMode = true;
		root.mouseChildren = false;
		label = new TextField();
		label.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
		label.selectable = false;
		label.width = width;
		label.height = height;
		label.y = (height - 17) / 2;
		root.addChild(label);
		root.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent) event.stopImmediatePropagation());
		root.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
			event.stopImmediatePropagation();
			if (enabled)
				this.action();
		});
		root.addEventListener(MouseEvent.ROLL_OVER, function(_) {
			over = true;
			draw();
		});
		root.addEventListener(MouseEvent.ROLL_OUT, function(_) {
			over = false;
			draw();
		});
		setText(text);
	}

	public function setText(text:String):Void {
		label.text = text;
		draw();
	}

	/** Greys the button out and ignores clicks, with a new label. */
	public function disable(text:String):Void {
		enabled = false;
		root.buttonMode = false;
		setText(text);
	}

	function draw():Void {
		var fill = !enabled ? 0x3A3A3A : over ? 0x5C7FB8 : 0x3D5A8A;
		root.graphics.clear();
		root.graphics.lineStyle(1, enabled ? 0x8FB0E0 : 0x555555);
		root.graphics.beginFill(fill, 0.95);
		root.graphics.drawRoundRect(0, 0, width, height, 6, 6);
		root.graphics.endFill();
		label.textColor = enabled ? 0xFFFFFF : 0x9A9A9A;
	}
}
