import Foundation
import Cocoa


/// Struct Object to represent a window info object, example like below:
/// (lldb) po windowInfo
/// (lldb) po windowInfo
///▿ WindowInfo
///  - order : nil
///  - windowID : nil
///  - windowName : ""
///  - ownerName : "系统偏好设置"
///  - layer : 0
///  ▿ frame : (802.0, 595.0, 668.0, 587.0)
///    ▿ origin : (802.0, 595.0)
///      - x : 802.0
///      - y : 595.0
///    ▿ size : (668.0, 587.0)
///      - width : 668.0
///      - height : 587.0
///  ▿ directDisplayID : Optional<UInt32>
///    - some : 69991672
///  ▿ mainDisplayBounds : (0.0, 0.0, 2560.0, 1440.0)
///    ▿ origin : (0.0, 0.0)
///      - x : 0.0
///      - y : 0.0
///    ▿ size : (2560.0, 1440.0)
///      - width : 2560.0
///      - height : 1440.0
struct WindowInfo{
    var order: Int?
    var windowID: CGWindowID?
    var windowName = ""
    var ownerName = ""
    var layer: Int32 = 0
    var frame = NSRect.zero
    var ownerPid: Int32

    private var directDisplayID: CGDirectDisplayID?
    private let mainDisplayBounds = CGDisplayBounds(CGMainDisplayID())
    lazy private var quartzScreenFrame: CGRect? = {
        return CGDisplayBounds(self.directDisplayID!)
    }()

    func directDisplayID(from frame: CGRect) -> CGDirectDisplayID {
        let unsafeDirectDisplayID = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: 1)
        unsafeDirectDisplayID.pointee = 1
        CGGetDisplaysWithRect(frame, 2, unsafeDirectDisplayID, nil)
        let directDisplayID = unsafeDirectDisplayID.pointee as CGDirectDisplayID
        return directDisplayID
    }

    init(item: [String: AnyObject]) {

        windowName = item[kCGWindowName as String] as? String ?? ""
        ownerName = item[kCGWindowOwnerName as String] as? String ?? ""
        layer = (item[kCGWindowLayer as String] as! NSNumber).int32Value
        ownerPid = (item[kCGWindowOwnerPID as String] as! NSNumber).int32Value
        let bounds = item[kCGWindowBounds as String] as! Dictionary<String, CGFloat>
        
        let cgFrame = NSRect(
            x: bounds["X"]!, y: bounds["Y"]!, width: bounds["Width"]!, height: bounds["Height"]!
        )

        var windowFrame = NSRectFromCGRect(cgFrame)
        directDisplayID = directDisplayID(from: windowFrame)
        windowFrame.origin = convertPosition(windowFrame)
        frame = windowFrame
    }
    
    func convertPosition(_ frame:NSRect) -> NSPoint {
        var convertedPoint = frame.origin
        let y = mainDisplayBounds.height - frame.height - frame.origin.y
        convertedPoint.y = y
        return convertedPoint
    }
}
