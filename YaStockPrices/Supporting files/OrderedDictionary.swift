//
//  OrderedDictionary.swift
//  YaStockPrices
//
//  Created by Elenasshu on 05.04.2021.
//

import Foundation

struct OrderedDictionary<KeyType: Hashable, ValueType> {
    
    typealias ArrayType = [KeyType]
    typealias DictionaryType = [KeyType: ValueType]
    
    var array = ArrayType()
    var dictionary = DictionaryType()
    
    var count: Int {
        return self.array.count
    }
    
    mutating func insert(forKey key: KeyType, value: ValueType, atIndex index: Int)
    {
        var adjustedIndex = index
        
        let existingValue = self.dictionary[key]
        if existingValue != nil {
            let existingIndex = self.array.firstIndex(of: key)!
            
            if existingIndex < index {
                adjustedIndex -= 1
            }
            self.array.remove(at: existingIndex)
        }
        
        self.array.insert(key, at:adjustedIndex)
        self.dictionary[key] = value

    }
    
    mutating func removeAtIndex(index: Int) -> (KeyType, ValueType)?
    {
        precondition(index < self.array.count, "Index out-of-bounds")
        
        let key = self.array.remove(at: index)
        
        guard let value = self.dictionary.removeValue(forKey: key) else { return nil}
        
        return (key, value)
    }
    
    subscript(key: KeyType) -> ValueType? {
        get {
            return self.dictionary[key]
        }
        set {
            if let _ = self.array.firstIndex(of: key) {
            } else {
                self.array.append(key)
            }
            
            self.dictionary[key] = newValue
        }
    }
    
    subscript(index: Int) -> (KeyType, ValueType) {
        get {
            precondition(index < self.array.count,
                         "Index out-of-bounds")
            
            let key = self.array[index]
            
            let value = self.dictionary[key]!
            
            return (key, value)
        }
    }
    
}
