//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import Cocoa

let synth = Synthesizer(sounds: [Sound(wave: saw, volume: 0.5), Sound(wave: triangle, volume: 0.5)])

let keyboardView = KeyboardView(synth: synth, octaves: 3)


/*:
## Envelope

The envelope of a synthesizer controls the volume at certain stages of a note being played.
It is commonly referred to as an ADSR envelope since it usually consists of four parameters:

- Attack: How long it takes for the volume to reach its peak
- Delay: How long it takes after the attack for the volume to fade to the sustain level
- Sustain: The amount by which the volume decays to while holding down the note
- Release: How long it takes after releasing the note for the volume to return to 0

In the `envelope` struct, the times are in seconds and sustain is an amount from 0 to 1.

*/
synth.envelope.attack = 0.5
synth.envelope.sustain = 0.2
synth.envelope.decay = 2
synth.envelope.release = 0.5

let attackSlider = CallbackSlider(value: synth.envelope.attack, minValue: 0, maxValue: 2) { synth.envelope.attack = $0 }
let sustainSlider = CallbackSlider(value: synth.envelope.sustain, minValue: 0, maxValue: 1) { synth.envelope.sustain = $0 }
let decaySlider = CallbackSlider(value: synth.envelope.decay, minValue: 0, maxValue: 2) { synth.envelope.decay = $0 }
let releaseSlider = CallbackSlider(value: synth.envelope.release, minValue: 0, maxValue: 2) { synth.envelope.release = $0 }

let stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
stackView.addView(attackSlider, in: .top)
stackView.addView(sustainSlider, in: .top)
stackView.addView(decaySlider, in: .top)
stackView.addView(releaseSlider, in: .top)
stackView.addView(keyboardView, in: .bottom)
stackView.orientation = .vertical

let view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
view.addSubview(stackView)

PlaygroundPage.current.liveView = view

//: [Next](@next)
