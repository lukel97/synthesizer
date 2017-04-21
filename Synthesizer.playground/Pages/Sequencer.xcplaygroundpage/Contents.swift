//: [Previous](@previous)

import Cocoa
import PlaygroundSupport
import AVFoundation

PlaygroundPage.current.needsIndefiniteExecution = true

var melodySynth = Synthesizer(sounds: [Sound(wave: sin, volume: 1), Sound(wave: square(phase: 0.9), volume: 1)])


/*:

## Sequencer

A `Sequencer` allows us to schedule multiple notes for a synthesizer to play.
You can create a `Sequencer` by specifying notes to be played, the speed to played at and how long the notes should be played for.

*/

/// Beat
/// Represents a length of time musically
/// The raw value is how many of the beat fits into a single common time bar
enum Beat: Int {
	case	semibreve = 1,
			minim = 2,
			crotchet = 4,
			halfTriplet = 6,
			quaver = 8,
			triplet = 12,
			semiquaver = 16,
			semidemiquaver = 32
}

/// Sequencer
/// A sequencer can be iterated over in a for-style loop to play various notes in sequence
struct Sequencer: Sequence, IteratorProtocol {
	typealias Element = Playable
	
	let playables: [Playable]
	let bpm: Double
	let beat: Beat
	init(playables: [Playable], bpm: Double = 120, beat: Beat = .crotchet) {
		self.playables = playables
		self.bpm = bpm
		self.beat = beat
	}
	
	var i = 0
	mutating func next() -> Playable? {
		//Wait between notes
		let beatLength = 4.0 / Double(beat.rawValue)
		usleep(UInt32(1.0e6 * (60.0 / bpm * beatLength)))
		
		let next = playables[i]
		i = (i + 1) % playables.count
		return next
	}
}

melodySynth.envelope.attack = 0.05
melodySynth.envelope.release = 0.1
melodySynth.envelope.sustain = 0.5
melodySynth.envelope.decay = 0.3

melodySynth.effects = [.distortion(decimation: 50, decimationMix: 20, ringModMix: 0, finalMix: 30) ,.reverb(smallLargeMix: 90, dryWetMix: 50, preDelay: 0.0)]


//Generate the arpeggio to Arpeggi/Weird Fishes by Radiohead
var weirdFishes = [Note]()
let triplets: [[Note]] = [[.D(4), .G(3), .E(3)],
                          [.E(4), .A(4), .FSharp(3)],
                          [.A(5), .E(4), .A(4)],
                          [.FSharp(4), .D(4), .G(3)]]
for triplet in triplets {
	(0...10).forEach { _ in weirdFishes += triplet }
	weirdFishes.removeLast()
}

/*:
With the sequencer we simply iterate over it with a `for` loop.
It will call the contents of the loop in time with the bpm and beat that we gave it.
In this example an extra, tiny delay has been added to allow the synthesizer to play the note and then release it quickly.
*/

//A delay between playing and releasing the note
let hold: Double = 1 / 80

for note in Sequencer(playables: weirdFishes, bpm: 120, beat: .triplet) {
	melodySynth.play(note)
	usleep(UInt32(1.0e6 * (60.0 / 120.0 * hold)))
	melodySynth.release()
}

/*:
This about covers everything in the playground.
Now go try playing about with the synthesizers for yourself!
*/
