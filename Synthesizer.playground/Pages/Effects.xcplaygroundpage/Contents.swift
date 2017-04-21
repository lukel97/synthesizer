//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import AVFoundation
import AudioToolbox

let synth = Synthesizer(sounds: [Sound(wave: sin, volume: 1.0)])

let keyboardView = KeyboardView(synth: synth)
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = keyboardView

/*:
## Effects
Because the `Synthesizer` class is powered by Core Audio underneath the hood, we can easily add effects to the sound that it produces.
The `effects` property takes an array of `Effect` enums, which wrap around standard Core Audio effect units.

- Example:
`synth.effects = [.highPass(cutoff: Note.E(5).freq)]`\
With the highpass effect frequencies get cut off below a certain frequency. In this example the lower notes on the keyboard become quieter.
*/



/// This trio of effects first distorts the sound, before giving it an echo through delay and finally adding reverb, which makes it sound as if it was in an empty large space

synth.effects = [.distortion(decimation: 50, decimationMix: 60, ringModMix: 100, finalMix: 50),
                 .delay(delayTime: 0.3, wetDryMix: 70, feedback: 30),
                 .reverb(smallLargeMix: 90, dryWetMix: 90, preDelay: 0.3)]

	
//: - Note: The order of the effects in the array determines the order in which the effects are applied - different orders can produce different sounds!
//:
//: [Next](@next)
