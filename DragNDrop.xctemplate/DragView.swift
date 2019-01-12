//___FILEHEADER___

import Cocoa

class DragView: NSView {
	private var inDragNDrop : Bool = false
	// Add your extensions to drop
	private var acceptedFileExtensions = ["txt"]
	@IBOutlet var progressIndicator: NSProgressIndicator!

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
	}

	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		inDragNDrop = true
		self.progressIndicator.isHidden = false
		self.setNeedsDisplay(self.bounds)

		if self.checkExtension(sender){
			return NSDragOperation.copy
		}

		return NSDragOperation()
	}

	override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
		self.inDragNDrop = true
		self.progressIndicator.isHidden = false
		self.setNeedsDisplay(self.bounds)
		return NSDragOperation.copy
	}

	override func draggingEnded(_ sender: NSDraggingInfo) {
		inDragNDrop = false
		self.setNeedsDisplay(self.bounds)
	}

	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {

		let pasteboard = sender.draggingPasteboard

		if let paths = pasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray {
			for path in paths {
				//Do something
				let suffix : String = URL(fileURLWithPath: (path as? String)!).pathExtension.lowercased()
				switch suffix {
				case "txt":
					self.fromTxt(path: path as! String)
				default:
					// Do default on non-trapped extensions
					break
				}
			}
		}

		self.progressIndicator.isHidden = true

		return true
	}

	fileprivate func checkExtension(_ sender: NSDraggingInfo) -> Bool {
		var accept : Bool = true

		if let paths = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray {
			for path in paths {
				let suffix : String = URL(fileURLWithPath: (path as? String)!).pathExtension
				if !self.acceptedFileExtensions.contains(suffix.lowercased()) {
					accept = false
				}
			}
		}
		return accept
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		// Drawing code here.

		if self.inDragNDrop {
			let bezierPath = NSBezierPath.init(rect: self.bounds)
			bezierPath.lineWidth = 12.0
			NSColor.controlAccentColor.set()
			bezierPath.stroke()
		}
	}

	fileprivate func fromTxt(path: String) -> Void {
		self.progressIndicator.isHidden = false
		self.progressIndicator.startAnimation(self)

		// Do stuff
		let url = URL(fileURLWithPath: path)
		let fullPath = url.path
		let ext = url.pathExtension
		let fileName = url.deletingPathExtension().lastPathComponent
		let filePath = url.deletingLastPathComponent().path
		let txt = "\(filePath)/\(fileName).\(ext)"

		print("Path: \(filePath)\nName: \(fileName)\nExtension: \(ext)\nFull Path: \(fullPath)")

		let commandlineAppURL = URL(fileURLWithPath: "/bin/cat")

		let task = Process()
		let pipe = Pipe()

		task.executableURL = commandlineAppURL
		task.arguments = [txt]
		task.standardOutput = pipe

		do{
			try task.run()
		}catch{}

		let handle = pipe.fileHandleForReading
		let data = handle.readDataToEndOfFile()
		print(String (data: data, encoding: String.Encoding.utf8)!)

		// Stop animation
		self.progressIndicator.stopAnimation(self)
		self.progressIndicator.isHidden = true
	}

}

