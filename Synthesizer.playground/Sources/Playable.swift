import Foundation

public protocol Playable {
	/// freq
	/// Returns the frequency of the playable item
	var freq: Float { get }
}

extension Float: Playable {
	public var freq: Float {
		return self
	}
}

extension Double: Playable {
	public var freq: Float {
		return Float(self)
	}
}

extension Int: Playable {
	public var freq: Float {
		return Float(self)
	}
}

/// Note
/// Provides pitches in a music-theory format
public enum Note: Playable, Strideable {
	
	case C(Int)
	case CSharp(Int)
	case D(Int)
	case EFlat(Int)
	case E(Int)
	case F(Int)
	case FSharp(Int)
	case G(Int)
	case GSharp(Int)
	case A(Int)
	case BFlat(Int)
	case B(Int)
	
	/// Returns whether the note is sharp or flat
	/// - Returns: True if sharp or flat, false otherwise
	public var isSharpOrFlat: Bool {
		switch self {
		case .BFlat, .CSharp, .EFlat, .FSharp, .GSharp:
			return true
		default:
			return false
		}
	}

	///	Returns how many semitones starting from A(0) the note is
	var semitones: Int {
		switch self {
		case .A(let octave):
			return octave * 12
		case .BFlat(let octave):
			return octave * 12 + 1
		case .B(let octave):
			return octave * 12 + 2
		case .C(let octave):
			return octave * 12 + 3
		case .CSharp(let octave):
			return octave * 12 + 4
		case .D(let octave):
			return octave * 12 + 5
		case .EFlat(let octave):
			return octave * 12 + 6
		case .E(let octave):
			return octave * 12 + 7
		case .F(let octave):
			return octave * 12 + 8
		case .FSharp(let octave):
			return octave * 12 + 9
		case .G(let octave):
			return octave * 12 + 10
		case .GSharp(let octave):
			return octave * 12 + 11
		}
	}
	
	public var freq: Float {
		let modifier = { (octave: Int) in
			return pow(2.0, Float(octave))
		}
		
		switch self {
		case .A(let octave):
			return 13.75 * modifier(octave)
		case .BFlat(let octave):
			return 14.57 * modifier(octave)
		case .B(let octave):
			return 15.435 * modifier(octave)
		case .C(let octave):
			return 16.35 * modifier(octave)
		case .CSharp(let octave):
			return 17.3 * modifier(octave)
		case .D(let octave):
			return 18.35 * modifier(octave)
		case .EFlat(let octave):
			return 19.45 * modifier(octave)
		case .E(let octave):
			return 20.60 * modifier(octave)
		case .F(let octave):
			return 21.83 * modifier(octave)
		case .FSharp(let octave):
			return 23.12 * modifier(octave)
		case .G(let octave):
			return 24.50 * modifier(octave)
		case .GSharp(let octave):
			return 25.96 * modifier(octave)
		}
	}
	
	//MARK: Stride protocol
	
	public typealias Stride = Int
	
	public func advanced(by n: Int) -> Note {
		let initial = self
		var note = initial
		
		//Going downwards
		if n < 0 {
			for _ in 0..<n {
				switch note {
				case .A(let octave):
					note = .GSharp(octave - 1)
				case .BFlat(let octave):
					note = .A(octave)
				case .B(let octave):
					note = .BFlat(octave)
				case .C(let octave):
					note = .B(octave)
				case .CSharp(let octave):
					note = .C(octave)
				case .D(let octave):
					note = .CSharp(octave)
				case .EFlat(let octave):
					note = .D(octave)
				case .E(let octave):
					note = .EFlat(octave)
				case .F(let octave):
					note = .E(octave)
				case .FSharp(let octave):
					note = .F(octave)
				case .G(let octave):
					note = .FSharp(octave)
				case .GSharp(let octave):
					note = .G(octave)
				}
			}
			return note
		}
		for _ in 0..<n {
			switch note {
			case .A(let octave):
				note = .BFlat(octave)
			case .BFlat(let octave):
				note = .B(octave)
			case .B(let octave):
				note = .C(octave)
			case .C(let octave):
				note = .CSharp(octave)
			case .CSharp(let octave):
				note = .D(octave)
			case .D(let octave):
				note = .EFlat(octave)
			case .EFlat(let octave):
				note = .E(octave)
			case .E(let octave):
				note = .F(octave)
			case .F(let octave):
				note = .FSharp(octave)
			case .FSharp(let octave):
				note = .G(octave)
			case .G(let octave):
				note = .GSharp(octave)
			case .GSharp(let octave):
				note = .A(octave + 1)
			}
		}
		return note
	}
	
	public func distance(to other: Note) -> Int {
		return other.semitones - semitones
	}
}
