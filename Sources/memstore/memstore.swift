import Foundation

fileprivate protocol Store {
    var timer: Timer? { get }
    var queue: DispatchQueue { get }
    var store: [String: TempValue] { get set }
}

public class Memstore: Store {
   fileprivate var timer: Timer?
   fileprivate let queue = DispatchQueue(label:"memstore", attributes: .concurrent)
   fileprivate var store = [String:TempValue]()
   
   init(interval: UInt = 0) {
       if interval > 0 {
           self.timer = Timer.scheduledTimer(withTimeInterval: Double(interval) ,repeats: true){ timer in 
                self.queue.async(flags: .barrier) {
                    self.walk {
                        if Int64(Date().timeIntervalSince1970) - $1.timeStamp > interval {
                            self.delete(id: $0)
                        }
                    }
                }
           }
       }
   }
}

// Mutable private functions
internal extension Memstore{
    
    func walk(handler:(String,TempValue)->Void) -> Void{
        self.store.forEach(handler)
    }

}

//Store immutable funcs
public extension Memstore {
    
    func keys() -> [String] {
        var result = [String]()
        self.queue.sync {
            result = Array(self.store.keys)
        }
        return result
    }

    func values() -> [Any] {
        var result = [Any]()
        self.queue.sync {
            result = Array(self.store.values.compactMap {
                return $0.rawValue
            })
        }
        return result
    }

    func get(id: String) -> Any? {
        var result: Any?
        self.queue.sync{
            if let val = self.store[id] {
                result = val.rawValue
            }
        }
        return result
    }
}

//Store mutable funcs
public extension Memstore {

   func insert(id: String, value: Any,completion: ((Bool)->Void)? = nil ){
        self.queue.async(flags: .barrier){
            if let _:TempValue = self.store[id] {
                completion?(false)
                return
            }
            self.store[id] = TempValue(value:value)
            completion?(true)
        }
    }

   func upsert(id: String, value: Any,completion: (()->Void)? = nil) -> Void {
        self.queue.async(flags: .barrier){
            self.store[id] = TempValue(value:value)
            completion?()
        }
    }

    func delete(id: String,completion: ((Any)->Void)? = nil) -> Void {
        self.queue.async(flags: .barrier){
            if let val:TempValue = self.store.removeValue(forKey:id) {
                completion?(val.rawValue)
            }
        }
    }
    
}