//: [Previous](@previous)

import Cocoa
import PlaygroundSupport
import AVFoundation

/*:
## Keyboard

This is a view that allows you to play specific notes on a synthesizer.
Open up the assistant editor to try it out, and then click on a key to play it.
You can specify more octaves on the keyboard with the `octaves` parameter.

*/

let synth = Synthesizer(sounds: [Sound(wave: sin, volume: 1.0), Sound(wave: square(), volume: 0.5)])

let keyboardView = KeyboardView(synth: synth)
PlaygroundPage.current.liveView = keyboardView



//: [Next](@next)
