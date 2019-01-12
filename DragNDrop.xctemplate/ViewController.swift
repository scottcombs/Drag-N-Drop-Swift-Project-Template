//___FILEHEADER___

import Cocoa

class ViewController: NSViewController {
	@IBOutlet var dragView: DragView!
	@IBOutlet var progressIndicator: NSProgressIndicator!
	@IBOutlet var textField: NSTextField!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

}


