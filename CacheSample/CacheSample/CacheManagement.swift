//
//  CacheManagement.swift
//  CacheSample
//
//  Created by Mac Mini 2021_1 on 20/09/2022.
//

import Foundation

final class CacheManagers<Key: Hashable, Value : Any> {
    
    private var cache = NSCache<KeyCache,ValueCache>()
    private var expirationTime = TimeInterval()
    
    public var countLimit:Int {
        get {
            return self.cache.countLimit
        }
        set {
            self.cache.countLimit = newValue
        }
    }
    
    init() {
        self.createCacheDirectory()
    }
    
    init( countLimit : Int, expireTimes: TimeInterval ) {
        self.createCacheDirectory()
        self.cache.countLimit = countLimit
        self.expirationTime = expireTimes
    }
    
    fileprivate func createCacheDirectory() {
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = searchPath[0] as NSString
        let component = path.appendingPathComponent("image.cache")
        if !FileManager.default.fileExists(atPath: component) {
            FileManager.default.createFile(atPath: component, contents: nil)
        }
    }
    
    public func insertValue(_ value : Value , forKey key: Key ) {
        cache.setObject(ValueCache.init(value), forKey: KeyCache.init(key))
    }
    
    public func valueForKey(_ key: Key ) -> Value? {
        let value = cache.object(forKey: KeyCache.init(key))
        return value?.value
    }
    
    public func removeValueforKey(_ key: Key ) {
        cache.removeObject(forKey: KeyCache.init(key))
    }
    
    public func removeAllValue() {
        cache.removeAllObjects()
    }
    
    func saveToFile() {
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = searchPath[0] as NSString
        let component = path.appendingPathComponent("image.cache")
        if FileManager.default.fileExists(atPath: component) {
            let data = Data()
            do {
                try data.write(to: URL(fileURLWithPath: component))
            }
            catch {
                fatalError("Save data to cache file failed")
            }
        }
    }
}

private extension CacheManagers {
    final class KeyCache : NSObject {
        let key : Key
        
        init (_ key : Key ) {
            self.key = key
        }
        
        override var hash: Int { return self.key.hashValue }
        
        // override equalable
        static func ==(lhs:KeyCache , rhs:KeyCache) -> Bool {
            return lhs.key == rhs.key
        }
    }
}

private extension CacheManagers {
    final class ValueCache {
        let value : Value
        var expirationTimes = TimeInterval()
        
        init (_ value : Value, expireTimes: TimeInterval = 0) {
            self.value = value
            self.expirationTimes = expireTimes
        }

    }
}

extension CacheManagers {
    subscript(key: Key) -> Value? {
        get {
            return valueForKey(key)
        }
        set {
            if newValue != nil {
                insertValue(newValue!, forKey: key)
                return
            }
            fatalError("Error when add object for key")
        }
    }
}

//extension CacheManagers : Codable where Key : Codable, Value : Codable {
//    convenience init(from decoder: Decoder) throws {
//        self.init()
//
//        let container = try decoder.singleValueContainer()
//        let entries = try container.decode([Value].self)
//        entries.forEach(insertValue)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(keyTracker.keys.compactMap(Value))
//    }
//}
