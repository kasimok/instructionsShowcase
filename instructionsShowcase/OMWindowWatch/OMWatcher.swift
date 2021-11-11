import Foundation
import AppKit

protocol OMWindowWatcherDelegate: AnyObject{
    func windowDidAppearOnScreen(windowInfo: WindowInfo)
    func windowDidMoved(windowInfo: WindowInfo)
    func windowDidDisappearFromScreen()
    func windowDidBecomeInactive()
}



class OMWindowWatcher: NSObject{
    /// target window size
    var windowSize: CGSize?
    /// window's owner name, localized string
    var windowOwnerName: String?
    /// window  name, for most window this is nil
    var windowName: String?
    
    var timer: Timer?
    
    weak var delegate: OMWindowWatcherDelegate?
    
    var onScreen: Bool = false
    
    var windowInfo: WindowInfo?
    
    var stopWatchOnFirstDisappear = true
    
    var timerUpdateInterval = 0.02
    
    var frontAndActive: Bool = false
    
    init(windowSize: CGSize?, windowOwnerName: String? = nil, windowName: String? = nil) {
        self.windowSize = windowSize
        self.windowOwnerName = windowOwnerName
        self.windowName = windowName
    }
    
    
    func startWatch(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timerUpdateInterval, target: self, selector: #selector(checkWindow), userInfo: nil, repeats: true)
    }
    
    func stopWatch(){
        timer?.invalidate()
    }
    
    @objc func checkWindow(){
        if let windowInfo = detectTargetWindow(with: windowSize, orName: windowName, orOwnerName: windowOwnerName){
            if onScreen == false{
                delegate?.windowDidAppearOnScreen(windowInfo: windowInfo)
                onScreen = true
                self.windowInfo = windowInfo
            }else if let previousWindowFrame = self.windowInfo?.frame{
                if previousWindowFrame != windowInfo.frame{
                    delegate?.windowDidMoved(windowInfo: windowInfo)
                }
            }
            
            if let app = NSRunningApplication(processIdentifier: windowInfo.ownerPid){
                if !app.isActive{
                    delegate?.windowDidBecomeInactive()
                }
            }
            
        }else{
            if onScreen == true{
                onScreen = false
                delegate?.windowDidDisappearFromScreen()
                windowInfo = nil
                if stopWatchOnFirstDisappear {timer?.invalidate()}
            }
        }
        
    }
    
    /// detect window with any match in frame size, name, or owner name.
    /// - Parameters:
    ///   - frameSize: window frame size
    ///   - orName: window name
    ///   - orOwnerName: window owner name
    /// - Returns: matched window info
    func detectTargetWindow(with frameSize: CGSize?, orName: String?, orOwnerName: String?) -> WindowInfo?{
        let listOptions = CGWindowListOption(arrayLiteral: [.optionOnScreenOnly,.excludeDesktopElements])
        let windowInfosRef = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for i in 0..<CFArrayGetCount(windowInfosRef) {
            
            let lineUnsafePointer: UnsafeRawPointer = CFArrayGetValueAtIndex(windowInfosRef, i)
            let lineRef = unsafeBitCast(lineUnsafePointer, to: CFDictionary.self)
            let dic = lineRef as Dictionary<NSObject, AnyObject>
            
            let info = WindowInfo(item: dic as! [String : AnyObject])
            
            if info.frame.size == frameSize || info.windowName == orName || info.ownerName == orOwnerName{
                return info
            }
        }
        return nil
    }
    
}
