import Foundation
import AVFoundation
import AudioToolbox


public func square(phase: Float = 0.5) -> (Float) -> Float {
	return { t in
		t > 2 * .pi * phase ? 1 : 0
	}
}

public func saw(_ t: Float) -> Float {
	return t - floor(t / (2 * .pi))
}

public func triangle(_ t: Float) -> Float {
	let a = t - floor(t + 0.5)
	let b = pow(-1.0, floor(t + 0.5))
	return 2 * a * b
}

public class Sound {
	public var wave: (Float) -> Float
	public var volume: Float
	private var currentPhase: Float = 0
	internal var synth: Synthesizer?
	
	public init(wave: @escaping (Float) -> Float, volume: Float) {
		self.wave = wave
		self.volume = volume
	}
	
	let renderCallback: AURenderCallback = { inRefCon, actionFlags, timestamp, busNumber, frameCount, outputData in
		let buffers = UnsafeMutableAudioBufferListPointer(outputData!)
		
		var soundPointer = inRefCon.assumingMemoryBound(to: Sound.self)
		
		var sound = soundPointer.pointee
		
		guard var synth = sound.synth else {
			return noErr
		}
		
		let period: Float = synth.sampleRate / (synth.playable ?? Note.C(3)).freq
		
		let secondsPassed = Float(Double(timestamp.pointee.mHostTime - synth.envTime) / 10e8)
		
		for frame in 0..<frameCount {
			
			let freqMod = synth.freqMod(sound.currentPhase * synth.freqModAmount)
			
			let waveAmplitude = sound.wave((sound.currentPhase / period * freqMod) * 2 * .pi)
			
			let amplitude: Float
			
			if synth.isPlaying {
				if secondsPassed < synth.envelope.attack {
					//Attack
					let attackAmount = min(1, secondsPassed / synth.envelope.attack)
					amplitude = waveAmplitude * attackAmount
					synth.sustainedLevel = attackAmount
				} else {
					let decayAmount = min(1, (secondsPassed - synth.envelope.attack) / synth.envelope.decay)
					let lerp = 1 + (synth.envelope.sustain - 1) * decayAmount
					
					synth.sustainedLevel = lerp
					//Decay
					amplitude = waveAmplitude * lerp
				}
			} else {
				//Release
				amplitude = waveAmplitude * synth.sustainedLevel * (1 - min(1, secondsPassed / synth.envelope.release))
			}
			
			for buffer in buffers {
				guard let data = buffer.mData else { continue }
				UnsafeMutablePointer<Float32>(data.assumingMemoryBound(to: Float32.self))[Int(frame)] = Float32(amplitude)
			}
			
			sound.currentPhase = fmod(sound.currentPhase + 1, period)
		}
		
		return noErr
	}
}

public class Synthesizer {
	
	///The current sound that is playing
	public private(set) var playable: Playable?
	
	public var effects = [Effect]() {
		didSet {
			check(status: AUGraphClearConnections(graph))
			
			var previousNode = mixerNode
			for effect in effects {
				var node = AUNode()
				
				var description = effect.description
				
				check(status: AUGraphAddNode(graph, &description, &node))
				
				var unit: AudioUnit?
				
				check(status: AUGraphNodeInfo(graph, node, nil, &unit))
				
				effect.setParameters(unit: &unit!)
				
				check(status: AUGraphConnectNodeInput(graph, previousNode, 0, node, 0))
				
				previousNode = node
			}
			
			check(status: AUGraphConnectNodeInput(graph, previousNode, 0, outputNode, 0))
			
			//Set render callbacks again
			for (index, sound) in sounds.enumerated() {
				let pointer = UnsafeMutablePointer<Sound>.allocate(capacity: 1)
				pointer.initialize(to: sound)
				
				var renderCallbackStruct = AURenderCallbackStruct(inputProc: sound.renderCallback, inputProcRefCon: pointer)
				
				check(status: AUGraphSetNodeInputCallback(graph, mixerNode, UInt32(index), &renderCallbackStruct))
			}
			
			check(status: AUGraphUpdate(graph, nil))
		}
	}
	
	public let sampleRate: Float
	
	fileprivate var envTime: UInt64 = 0
	//Used for transitioning from attack/decay -> release
	fileprivate var sustainedLevel: Float = 0
	
	public struct Envelope {
		public var attack, decay, sustain, release: Float
	}
	
	public var envelope = Envelope(attack: 0, decay: 0, sustain: 1, release: 0)
	
	public var freqMod: (Float) -> Float = { _ in 1 }
	public var freqModAmount: Float = 1
	
	fileprivate var isPlaying = false
	
	let outputUnit, mixerUnit: AudioUnit
	var outputNode = AUNode(), mixerNode = AUNode()
	let graph: AUGraph

	public let sounds: [Sound]
	
	public init(sounds: [Sound], sampleRate: Float = 44100) {
		self.sounds = sounds
		self.sampleRate = sampleRate
		
		var newGraph: AUGraph?
		check(status: NewAUGraph(&newGraph))
		
		graph = newGraph!
		
		var outputDescription = AudioComponentDescription(componentType: kAudioUnitType_Output,
		                                            componentSubType: kAudioUnitSubType_DefaultOutput,
		                                            componentManufacturer: kAudioUnitManufacturer_Apple,
		                                            componentFlags: 0, componentFlagsMask: 0)
		
		check(status: AUGraphAddNode(graph, &outputDescription, &outputNode))
		
		var mixerDesc = AudioComponentDescription(componentType: kAudioUnitType_Mixer,
		                                          componentSubType: kAudioUnitSubType_MultiChannelMixer,
		                                          componentManufacturer: kAudioUnitManufacturer_Apple,
		                                          componentFlags: 0,
		                                          componentFlagsMask: 0)
		
		check(status: AUGraphAddNode(graph, &mixerDesc, &mixerNode))
		
		check(status: AUGraphConnectNodeInput(graph, mixerNode, 0, outputNode, 0))
		
		check(status: AUGraphOpen(graph))
		
		var newOutputUnit: AudioUnit?
		check(status: AUGraphNodeInfo(graph, outputNode, nil, &newOutputUnit))
		
		var newMixerUnit: AudioUnit?
		check(status: AUGraphNodeInfo(graph, mixerNode, nil, &newMixerUnit))
		
		
		self.outputUnit = newOutputUnit!
		self.mixerUnit = newMixerUnit!
		
		//Assign sounds synths
		sounds.forEach { $0.synth = self }
		
		//Set sounds for the mixer

		var numberOfBuses = UInt32(sounds.count)
		check(status: AudioUnitSetProperty(mixerUnit,
		                           kAudioUnitProperty_ElementCount,
		                           kAudioUnitScope_Input,
		                           0,
		                           &numberOfBuses,
		                           UInt32(MemoryLayout<UInt32>.size)))
		
		//Set render callbacks
		for (index, sound) in sounds.enumerated() {
			let pointer = UnsafeMutablePointer<Sound>.allocate(capacity: 1)
			pointer.initialize(to: sound)
			
			var renderCallbackStruct = AURenderCallbackStruct(inputProc: sound.renderCallback, inputProcRefCon: pointer)
			
			check(status: AUGraphSetNodeInputCallback(graph, mixerNode, UInt32(index), &renderCallbackStruct))
			
			//Set volumes while we're at it
			check(status: AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, UInt32(index), sound.volume * 0.5, 0))
		}
		
		check(status: AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, 0.5, 0))

		
		//Set stream quality and stuff
		var streamDescription = AudioStreamBasicDescription()
		streamDescription.mSampleRate = Double(self.sampleRate)
		streamDescription.mFormatID = kAudioFormatLinearPCM
		streamDescription.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved
		streamDescription.mFramesPerPacket = 1
		streamDescription.mChannelsPerFrame = 2
		streamDescription.mBitsPerChannel = UInt32(MemoryLayout<Float32>.size * 8)
		streamDescription.mBytesPerFrame = UInt32(MemoryLayout<Float32>.size)
		streamDescription.mBytesPerPacket = UInt32(MemoryLayout<Float32>.size)
		
		check(status: AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamDescription, UInt32(MemoryLayout<AudioStreamBasicDescription>.size)))
		check(status: AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &streamDescription, UInt32(MemoryLayout<AudioStreamBasicDescription>.size)))
		
		check(status: AUGraphInitialize(graph))
		
		check(status: AUGraphStart(graph));
		
		//Use this for debugging
//		CAShow(UnsafeMutablePointer<AUGraph>(graph))
	}
	
	/// Begins playing the specified item
	public func play(_ playable: Playable) {
		self.playable = playable
		isPlaying = true
		envTime = mach_absolute_time()
	}
	
	/// Releases the currently played item
	public func release() {
		isPlaying = false
		envTime = mach_absolute_time()
	}
	
	/// Stops the synthesizer
	public func stop() {
		AUGraphStop(graph)
	}
	
	/// Starts the synthesizer
	public func start() {
		AUGraphStart(graph)
	}
	
}

func check(status: OSStatus) {
	if status != noErr {
		print("error occured with code \(status)")
	}
}
