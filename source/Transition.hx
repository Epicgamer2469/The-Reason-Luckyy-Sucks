package;

import haxe.Constraints.Function;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;

class Transition extends FlxTypedGroup<FlxSprite>{
    static inline final SIDE = 80;
    static inline final DURATION = .25;
    static inline final DELAY = .0035;

    public function new() {
        super();

        for (x in 0...(Math.ceil(FlxG.width / SIDE))) {
            for (y in 0...(Math.ceil(FlxG.height / SIDE))) {
                var square = new FlxSprite(x * SIDE, y * SIDE);
                square.makeGraphic(SIDE, SIDE, 0xff060608);
                square.ID = x * y;
                add(square);
            }
        }
    }

    public function open(?callback:() -> Void) {
        forEach(square -> {
            FlxTween.tween(square.scale, {x: 0.01, y: 0.01}, DURATION, {startDelay: DELAY * square.ID, onComplete: twn -> {
                square.visible = false;
            }});
        });
        new FlxTimer().start(DURATION + (DELAY * members.length), tmr -> callback());
    }

    public function close(?callback:() -> Void) {
        forEach(square -> {
            square.visible = true;
            FlxTween.tween(square.scale, {x: 1, y: 1}, DURATION, {startDelay: DELAY * square.ID});
        });
        //new FlxTimer().start(1, tmr -> callback());
        new FlxTimer().start(DURATION + (DELAY * members.length), tmr -> callback());
    }
}