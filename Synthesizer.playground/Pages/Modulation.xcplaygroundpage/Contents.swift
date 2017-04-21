//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import Cocoa

PlaygroundPage.current.needsIndefiniteExecution = true

/*:
## Modulation

The wave property on `Sound` modifies the amplitude of the wave.
However we can also modify the frequency of the wave with the `freqMod` property.
It doesn't necessarily need to be a sine wave - we can change this with another function.

In this example the synthesizer has it's frequency modulated by `sin`. You can change the amount by which the frequency is modulated with the slider in the live view.
*/

let synth = Synthesizer(sounds: [Sound(wave: triangle, volume: 0.3), Sound(wave: sin, volume: 0.3)])
synth.freqMod = sin
synth.freqModAmount = 0.4
synth.play(Note.C(3))

class WaveformView: NSView {
	
	let synth: Synthesizer
	
	init(synth: Synthesizer) {
		self.synth = synth
		super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 150))
	}
	
	required init?(coder: NSCoder) {
		synth = coder.decodeObject(forKey: "synth") as! Synthesizer
		super.init(coder: coder)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		var colors: [NSColor] = [.red, .green, .blue, .yellow]
		
		let yOrigin = bounds.height / 4
		
		for (index, sound) in synth.sounds.enumerated() {
			let path = NSBezierPath()
			path.move(to: NSPoint(x: 0, y: yOrigin))
			
			colors[index % colors.count].setStroke()	//Cycle through the colors
			
			for t in stride(from: Float(0), to: 8 * .pi, by: 0.1) {
				
				let freqMod = synth.freqMod(t * synth.freqModAmount)
				
				let waveAmplitude = sound.wave(t * freqMod)
				
				path.line(to: NSPoint(x: bounds.width * CGFloat(t / (2 * .pi)), y: CGFloat(waveAmplitude) * yOrigin + yOrigin))
			}
			
			path.stroke()
		}
	}
}

let waveformView = WaveformView(synth: synth)

let slider = CallbackSlider(value: synth.freqModAmount, minValue: 0, maxValue: 1) { synth.freqModAmount = $0 }

slider.mouseUpCallback = { _ in waveformView.setNeedsDisplay(waveformView.bounds) }


let stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
stackView.addView(waveformView, in: .top)
stackView.addView(slider, in: .bottom)
stackView.orientation = .vertical

let view = NSView(frame: stackView.bounds)
view.addSubview(stackView)
PlaygroundPage.current.liveView = view

//: [Next](@next)
