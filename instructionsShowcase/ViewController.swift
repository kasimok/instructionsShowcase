//
//  ViewController.swift
//  instructionsShowcase
//
//

import Cocoa

let kSecPrefUrl = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"


class ViewController: NSViewController {
    
    @IBOutlet weak var showPrefBtn: NSButton!
    
    var watcher: OMWindowWatcher = OMWindowWatcher(windowSize: CGSize(width: 668, height: 587))
    
    var omInstructions: OMAuxiliaryInstructionsPanel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func showSecPrefAction(_ sender: Any) {
        
        let url = URL(string: kSecPrefUrl)!
        
        NSWorkspace.shared.open(url)
        
        watcher.delegate = self
        
        watcher.startWatch()
        
    }
    
    
    
    
}

extension ViewController: OMWindowWatcherDelegate,NSWindowDelegate{
    func windowDidMoved(windowInfo: WindowInfo) {
        self.omInstructions?.setFrame(CGRect(origin: windowInfo.frame.origin.applying(CGAffineTransform.init(translationX: 0, y: -232)), size: CGSize(width: 668, height: 446)), display: true)
    }
    
    func windowDidAppearOnScreen(windowInfo: WindowInfo) {
        
        debugPrint("Bingo!")
        
        let rect = CGRect(origin: windowInfo.frame.origin.applying(CGAffineTransform.init(translationX: 0, y: -232)), size: CGSize(width: 668, height: 446))
        
        omInstructions = OMAuxiliaryInstructionsPanel(contentRect: rect, styleMask: [.nonactivatingPanel, .borderless, .hudWindow, .closable], backing: .buffered, defer: false)
        
        self.omInstructions!.backgroundColor = .clear
        
        let imageView = NSImageView(frame: CGRect(origin: .zero, size: CGSize(width: 668, height: 446)))
        
        imageView.autoresizingMask = [.width,.height]
        
        imageView.image = NSImage(named: "InstructionsView")
        
        self.omInstructions!.contentView?.addSubview(imageView)
        
        self.omInstructions!.imageView = imageView
            
        self.omInstructions!.level = .floating
        
        self.omInstructions!.makeKeyAndOrderFront(self)
                                  
        self.omInstructions?.delegate = self
        
        self.omInstructions?.ignoresMouseEvents = true
        
        
    }
    
    func windowDidDisappearFromScreen() {
        debugPrint("die")
        self.omInstructions?.close()
    }
    
}




class OMAuxiliaryInstructionsPanel: NSPanel{
    var imageView: NSImageView!
}
