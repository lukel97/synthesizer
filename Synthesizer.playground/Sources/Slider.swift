import Foundation
import Cocoa

public class CallbackSlider: NSSlider {
	
	public var callback: ((Float) -> Void)?
	public var mouseUpCallback: ((Float) -> Void)?
	
	public init(value: Float, minValue: Double, maxValue: Double, callback: @escaping (Float) -> Void) {
		self.callback = callback
		super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 20))
		self.floatValue = value
		self.minValue = minValue
		self.maxValue = maxValue
		self.target = self
		self.action = #selector(CallbackSlider.updateValue)
	}
	
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func updateValue() {
		callback?(self.floatValue)
	}
	
	override public func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		mouseUpCallback?(self.floatValue)
	}
}
