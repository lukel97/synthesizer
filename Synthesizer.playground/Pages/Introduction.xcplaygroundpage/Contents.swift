import Foundation
import PlaygroundSupport

/*:
# Synthesizer Playground
## By Luke Lau for WWDC 2017
### Powered by Core Audio

[Visually playing notes with KeyboardView](Keyboard)

[Modifying the envelope](Envelope)

[Frequency modulation](Modulation)

[Adding effects with AVUnitEffects](Effects)

[Sequencing notes with Sequencer](Sequencer)

## Synthesizer

Synthesizers are instruments that create sounds through electronic signals.

In this playground they are represented by the `Synthesizer` class.
A `Synthesizer` is made up of multiple `Sound`s.
Each `Sound` is a wave - like a sine wave, or a square wave.
Different waves produce different sounds, and so by layering up multiple waves we can give a `Synthesizer` interesting tones and timbres.


Below is a simple sine wave made into a `Sound` object
*/

let sineSound = Sound(wave: sin, volume: 1.0)

/*:
Here we've created a `Synthesizer` to play the sound above.
We can give it a frequency like 440HZ, or a note such as C4.
*/

let sineSynth = Synthesizer(sounds: [sineSound])
sineSynth.play(Note.C(4))
sleep(5)
sineSynth.play(440)
sleep(5)
sineSynth.stop()

/*:
Below are some more examples of waves that we can generate.
Be sure to check out the graphs of the waves by inspecting them in the sidebar!
*/

let graphableSine: (Float) -> Float = { t in
	return sin(t)
}
let graphableSineSynth = Synthesizer(sounds: [Sound(wave: graphableSine, volume: 1)])
graphableSineSynth.play(Note.C(3))
usleep(UInt32(10e6 * 0.01))
graphableSineSynth.stop()

let square: (Float) -> Float = { t in
	return t > .pi ? 1 : 0	//Inspect me in the sidebar
}
let squareSynth = Synthesizer(sounds: [Sound(wave: square, volume: 1)], sampleRate: 8000)
squareSynth.play(Note.C(3))
usleep(UInt32(10e6 * 0.01))
squareSynth.stop()

let pulse: (Float) -> Float = { t in
	return t > .pi * 0.3 ? 1 : 0	//Inspect me in the sidebar
}
let pulseSynth = Synthesizer(sounds: [Sound(wave: pulse, volume: 1)], sampleRate: 8000)
pulseSynth.play(Note.C(3))
usleep(UInt32(10e6 * 0.01))
pulseSynth.stop()

let triangle: (Float) -> Float = { t in
	let a = t - floor(t + 0.5)
	let b = pow(-1.0, floor(t + 0.5))
	return 2 * a * b	//Inspect me in the sidebar
}
let triangleSynth = Synthesizer(sounds: [Sound(wave: triangle, volume: 1)], sampleRate: 8000)
triangleSynth.play(Note.C(3))
usleep(UInt32(10e6 * 0.01))
triangleSynth.stop()

let saw: (Float) -> Float = { t in
	return t - floor(t / (2 * .pi))	//Inspect me in the sidebar
}
let sawSynth = Synthesizer(sounds: [Sound(wave: saw, volume: 1)], sampleRate: 8000)
sawSynth.play(Note.C(3))
usleep(UInt32(10e6 * 0.01))
sawSynth.stop()

let noise: (Float) -> Float = { t in
	return Float(1.0 - Float(arc4random()) / Float(UINT32_MAX / 2))	//Inspect me in the sidebar
}
let noiseSynth = Synthesizer(sounds: [Sound(wave: noise, volume: 1)], sampleRate: 8000)
noiseSynth.play(Note.C(3))
usleep(UInt32(10e6 * 0.01))
noiseSynth.stop()

/*:
- Note:
The above synthesizers have had their sample rate lowered.
In order to visualise the graphs the code must be run from inside the playground itself.
This is interpreted which is a lot slower than compiled code inside the Sources folder, and trying to play it at the standard 44100HZ sample rate may cause Core Audio to be choppy or fail

[Next](@next)
*/
