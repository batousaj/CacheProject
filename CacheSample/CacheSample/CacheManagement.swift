//
//  CacheManagement.swift
//  CacheSample
//
//  Created by Mac Mini 2021_1 on 20/09/2022.
//

import Foundation

final class CacheManagers<Key: Hashable, Value : Any> {
    
    private var cache = NSCache<KeyCache,ValueCache>()
    private var keyTrack = KeyTracking()
    private var dateProvider : () -> Date?
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
        self.dateProvider = Date.init
        
        let success = createCacheDirectory()
        if success {
            print("Cache file create successed")
        } else {
            print("Cache file create failed")
        }
    }
    
    init( countLimit : Int, expireTimes: TimeInterval = 10, dateProvide : @escaping () -> Date? ) {
        self.cache.countLimit = countLimit
        self.dateProvider = dateProvide
        self.expirationTime = expireTimes
    }
    
    fileprivate func createCacheDirectory() -> Bool {
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = searchPath[0] as NSString
        let component = path.appendingPathComponent("image.cache")
        if !FileManager.default.fileExists(atPath: component) {
            return FileManager.default.createFile(atPath: component, contents: nil)
        }
        return true
    }
    
    public func insertValue(_ value : Value , forKey key: Key ) {
        let keyCache = KeyCache(key)
        keyTrack.append(keyCache)
        let Date = Date()
        let date = Date.addingTimeInterval(self.expirationTime)
        cache.setObject(ValueCache(value,expireTimes: date), forKey: keyCache)
    }
    
    public func valueForKey(_ key: Key ) -> Value? {
        for key_ in self.keyTrack.keys {
            if key_.isEqual(KeyCache(key)) {
                
                guard let value = cache.object(forKey: key_) else {
                    return nil
                }
                
                guard let date = dateProvider(), date < value.expirationTimes else {
                    // Discard values that have expired
                    removeValueforKey(key)
                    return nil
                }
                
                return value.value
            }
        }
        return nil
    }
    
    public func removeValueforKey(_ key: Key ) {
        cache.removeObject(forKey: KeyCache(key))
    }
    
    public func removeAllValue() {
        cache.removeAllObjects()
    }
    
    public func numberOfKeys() -> Int {
        return keyTrack.keys.count
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
        override func isEqual(_ object: Any?) -> Bool {
            guard let object_ = object as? KeyCache else {
                return false
            }
            return object_.key == self.key
        }
    }
}

private extension CacheManagers {
    final class ValueCache  {
        let value : Value
        var expirationTimes = Date()
        
        init (_ value : Value) {
            self.value = value
        }

        init (_ value : Value, expireTimes: Date) {
            self.value = value
            self.expirationTimes = expireTimes
        }

    }
}

extension CacheManagers.ValueCache: Codable where Key: Codable, Value: Codable {}

private extension CacheManagers {
    private class KeyTracking {
        var keys = Set<KeyCache>()
        
        init() {}
        
        func append(_ key: KeyCache) {
            keys.insert(key)
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

extension CacheManagers : Codable where Key : Codable, Value : Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.singleValueContainer()
        let decode = try container.decode([decodePackage].self)
        try decode.forEach(value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTrack.keys.compactMap({ keyCache in
            return try insert(keyCache)
        }))
    }
    
    struct decodePackage : Decodable {
        let key : Key
        let value : Value
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.key = try container.decode(Key.self)
            self.value = try container.decode(Value.self)
        }
    }
    
    fileprivate func insert(_ key : KeyCache) throws -> ValueCache? {
        
        guard let value = cache.object(forKey: key) else {
            return nil
        }
        
        guard let date = dateProvider(), date < value.expirationTimes else {
            // Discard values that have expired
            removeValueforKey(key.key)
            return nil
        }
        
        return value
    }
    
    fileprivate func value(_ package : decodePackage) throws {
        let key = KeyCache(package.key)
        self.keyTrack.append(key)
        let Date = Date()
        let date = Date.addingTimeInterval(self.expirationTime)
        cache.setObject(ValueCache(package.value, expireTimes: date), forKey:key)
    }
    
    func saveToFile(options: OptionsWrite) throws {
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = searchPath[0] as NSString
        let component = path.appendingPathComponent("image.cache")
        print("path :\(component)")
        if FileManager.default.fileExists(atPath: component) {
            let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: component))
            let data = try JSONEncoder().encode(self)
            
            if options == .kOverwrite {
                fileHandle.write(data)
            } else if options == .kWithoutOverwrite {
                try fileHandle.seek(toOffset: fileHandle.seekToEndOfFile())
                fileHandle.write(data)
            }
            
            fileHandle.closeFile()
        } else {
            let success = self.createCacheDirectory()
            if success {
                let data = try JSONEncoder().encode(self)
                try data.write(to: URL(fileURLWithPath: component))
            }
        }
    }
    
    func readFromFile() throws {
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = searchPath[0] as NSString
        let component = path.appendingPathComponent("image.cache")
        print("path :\(component)")
        if FileManager.default.fileExists(atPath: component) {
            let dataDecoded = try Data(contentsOf: URL(fileURLWithPath: component))
            let data = try JSONDecoder().decode([decodePackage].self, from: dataDecoded)
            for data_ in data {
                self.insertValue(data_.value, forKey: data_.key)
            }
        }
    }
    
}

