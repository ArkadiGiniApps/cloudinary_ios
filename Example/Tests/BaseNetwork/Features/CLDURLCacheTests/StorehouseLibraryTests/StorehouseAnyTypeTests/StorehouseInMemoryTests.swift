//
//  StorehouseInMemoryTests.swift
//
//  Copyright (c) 2020 Cloudinary (http://cloudinary.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

@testable import Cloudinary
import Foundation
import XCTest

class StorehouseInMemoryTests: XCTestCase {

    var sut : StorehouseInMemory<String>!
    
    override func setUp() {
        super.setUp()
        
        let expiryDate    : Date             = Date()
        let expiry        : StorehouseExpiry = .date(expiryDate)
        let countLimit    : UInt             = 100_000_000
        let totalCostLimit: UInt             = 100_000_000
        let configuration                    = StorehouseConfigurationInMemory(expiry: expiry, countLimit: countLimit, totalCostLimit: totalCostLimit)
        
        sut = StorehouseInMemory(configuration: configuration)
    }
    
    override func tearDownWithError() throws {
        try? sut.removeAll()
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - init
    func test_init_shouldStoreDefaultProperties() {
        
        // Given
        let defaultMemoryCapacity     = NSNotFound
        let defaultCurrentMemoryUsage = NSNotFound
        
        let expiryDate    : Date             = Date()
        let expiry        : StorehouseExpiry = .date(expiryDate)
        let countLimit    : UInt             = 9
        let totalCostLimit: UInt             = 11
        let configuration                    = StorehouseConfigurationInMemory(expiry: expiry, countLimit: countLimit, totalCostLimit: totalCostLimit)
        
        // When
        let uninitializedSut: StorehouseInMemory<String> = StorehouseInMemory(configuration: configuration)
        
        // Then
        XCTAssertEqual(uninitializedSut.memoryCapacity, defaultMemoryCapacity, "default value should be equal to expected value")
        XCTAssertEqual(uninitializedSut.currentMemoryUsage, defaultCurrentMemoryUsage, "default value should be equal to expected value")
    }
    
    // MARK: - funcs
    func test_funcs_emptyEntry_shouldReturnNil() {
        
        // When
        let entry = try? sut.entry(forKey: "key")
        
        // Then
        XCTAssertNil(entry, "uninserted value should be nil")
    }
    func test_funcs_setObjectAndEntry_objectShouldBeSet() {
        
        // Given
        let objectToSave   = "objectToSave"
        let savedObjectKey = "key"
        
        // When
        try? sut.setObject(objectToSave, forKey: savedObjectKey)
        let entry = try? sut.entry(forKey: savedObjectKey).object
        
        // Then
        XCTAssertEqual(entry, objectToSave, "object should be set")
    }
    func test_funcs_removeAll_shouldReturnNil() {
        
        // Given
        let objectToSave   = "objectToSave"
        let savedObjectKey = "key"
        
        // When
        try? sut.setObject(objectToSave, forKey: savedObjectKey)
        try? sut.removeAll()
        
        let entry = try? sut.entry(forKey: savedObjectKey).object
        
        // Then
        XCTAssertNil(entry, "removed value should be nil")
    }
    func test_funcs_removeByKey_shouldReturnNil() {
        
        // Given
        let objectToSave   = "objectToSave"
        let savedObjectKey = "key"
        
        // When
        try? sut.setObject(objectToSave, forKey: savedObjectKey)
        try? sut.removeObject(forKey: savedObjectKey)
        
        let entry = try? sut.entry(forKey: savedObjectKey).object
        
        // Then
        XCTAssertNil(entry, "removed value should be nil")
    }
    func test_funcs_removeObjectIfExpired_shouldReturnNil() {
        
        // Given
        let objectToSave   = "objectToSave"
        let savedObjectKey = "key"
        
        // When
        try? sut.setObject(objectToSave, forKey: savedObjectKey)
        try? sut.removeObjectIfExpired(forKey: savedObjectKey)
        
        let entry = try? sut.entry(forKey: savedObjectKey).object
        
        // Then
        XCTAssertNil(entry, "removed value should be nil")
    }
    func test_funcs_removeExpiredObjects_shouldReturnNil() {
        
        // Given
        let objectToSave1   = "objectToSave1"
        let savedObjectKey1 = "key1"
        let objectToSave2   = "objectToSave2"
        let savedObjectKey2 = "key2"
        
        // When
        try? sut.setObject(objectToSave1, forKey: savedObjectKey1)
        try? sut.setObject(objectToSave2, forKey: savedObjectKey2)
        try? sut.removeExpiredObjects()
        
        let entry1 = try? sut.entry(forKey: savedObjectKey1).object
        let entry2 = try? sut.entry(forKey: savedObjectKey2).object
        
        // Then
        XCTAssertNil(entry1, "removed value should be nil")
        XCTAssertNil(entry2, "removed value should be nil")
    }
    func test_funcs_removeStoredObjects_shouldReturnNil() {
        
        // Given
        let objectToSave1   = "objectToSave1"
        let savedObjectKey1 = "key1"
        let objectToSave2   = "objectToSave2"
        let savedObjectKey2 = "key2"
        
        // When
        try? sut.setObject(objectToSave1, forKey: savedObjectKey1)
        try? sut.setObject(objectToSave2, forKey: savedObjectKey2)
        try? sut.removeStoredObjects(since: Date())
        
        let entry1 = try? sut.entry(forKey: savedObjectKey1).object
        let entry2 = try? sut.entry(forKey: savedObjectKey2).object
        
        // Then
        XCTAssertNil(entry1, "removed value should be nil")
        XCTAssertNil(entry2, "removed value should be nil")
    }
}
