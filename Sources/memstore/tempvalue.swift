import Foundation

struct TempValue {
    var rawValue: Any
    var timeStamp: Int64
    
    init(value raw: Any) {
        self.rawValue = raw
        self.timeStamp = Int64(Date().timeIntervalSince1970);
    }
}