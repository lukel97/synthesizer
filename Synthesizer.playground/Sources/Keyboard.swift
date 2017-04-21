import Foundation
import Cocoa

let keySize = CGSize(width: 40, height: 150)

/// KeyboardView
/// Provides an interactive keyboard to play `Synthesizer`s on
/// - SeeAlso: `Synthesizer`
public class KeyboardView: NSView {
	
	let synth: Synthesizer
	
	public init(synth: Synthesizer, octaves: Int = 2) {
		self.synth = synth
		
		//Get the number of white keys in the entire keyboard so we can work out the width
		let whiteKeyCount = stride(from: Note.C(3), to: Note.C(3 + octaves), by: 1).filter { !$0.isSharpOrFlat }.count
		
		super.init(frame: CGRect(x: 0, y: 0, width: CGFloat(whiteKeyCount) * keySize.width, height: keySize.height))
		
		var x: CGFloat = 0
		//Add each note as a key
		for note in stride(from: Note.C(3), to: Note.C(3 + octaves), by: 1) {
			let view: WhiteKeyView
			if note.isSharpOrFlat {	//Add a black key if it is a sharp
				view = BlackKeyView(note: note, synth: synth)
				var frame = view.frame
				frame.origin.x = x - (frame.width * 0.5)
				frame.origin.y = self.frame.height - frame.height
				view.frame = frame
			} else {	//Otherwise add a white key
				view = WhiteKeyView(note: note, synth: synth)
				var frame = view.frame
				frame.origin.x = x
				view.frame = frame
				x += frame.width
			}
			addSubview(view)
			
			//Sort the views so that the black keys are on top
			self.sortSubviews({ view1, view2, _ in
				if view1 is BlackKeyView {
					return .orderedDescending
				} else if view2 is BlackKeyView {
					return .orderedAscending
				}
				return .orderedSame
			}, context: nil)
		}
	}
	
	required public init?(coder: NSCoder) {
		self.synth = coder.decodeObject(forKey: "synth") as! Synthesizer
		super.init(coder: coder)
	}
	
	class BlackKeyView: WhiteKeyView {
		
		override init(note: Note, synth: Synthesizer) {
			super.init(note: note, synth: synth)
			var frame = self.frame
			frame.size.width = keySize.width / 2
			frame.size.height = keySize.height * 2 / 3
			self.frame = frame
		}
		
		override func draw(_ dirtyRect: NSRect) {
			NSColor.black.setFill()
			NSRectFill(bounds)
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
		}
	}
	
	class WhiteKeyView: NSView {
		
		let synth: Synthesizer
		let note: Note
		var isDown = false
		
		init(note: Note, synth: Synthesizer) {
			self.note = note
			self.synth = synth
			
			super.init(frame: CGRect(origin: .zero, size: keySize))
		}
		
		override func draw(_ dirtyRect: NSRect) {
			(isDown ? NSColor.lightGray : NSColor.white).setFill()
			NSRectFill(bounds)
			let path = NSBezierPath(rect: bounds)
			NSColor.lightGray.setStroke()
			path.stroke()
		}
		
		override func mouseDown(with event: NSEvent) {
			synth.play(note)
			isDown = true
			setNeedsDisplay(bounds)
		}
		
		override func mouseUp(with event: NSEvent) {
			synth.release()
			isDown = false
			setNeedsDisplay(bounds)
		}
		
		required init?(coder: NSCoder) {
			self.note = coder.decodeObject(forKey: "note") as! Note
			self.synth = coder.decodeObject(forKey: "synth") as! Synthesizer
			super.init(coder: coder)
		}
	}
}
