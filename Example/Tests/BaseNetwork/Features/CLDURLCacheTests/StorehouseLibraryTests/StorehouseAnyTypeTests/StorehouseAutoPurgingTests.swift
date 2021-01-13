//
//  StorehouseAutoPurgingTests.swift
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

class StorehouseAutoPurgingTests: XCTestCase {

    var sut      : StorehouseAutoPurging<String>!
    var expireNow: StorehouseExpiry = .date(Date())
    
    override func setUp() {
        super.setUp()
        
        createSut()
    }
    
    func createSut() {
        
        let expiryDate    : Date             = Date()
        let expiry        : StorehouseExpiry = .date(expiryDate)
        let memory        : Int              = 100_000_000
        let afterPurge    : Int              = 60_000_000
        
        let configuration = StorehouseConfigurationAutoPurging(expiry: expiry, memory: memory, preferredMemoryUsageAfterPurge: afterPurge)
        let transformer   = WarehouseTransformerFactory.forCodable(ofType: String.self)
        
        sut = StorehouseAutoPurging(configuration: configuration, transformer: transformer)
    }
    
    override func tearDownWithError() throws {
        try? sut.removeAll()
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - init
    func test_init_shouldStoreDefaultProperties() {
        
        // Given
        let expiryDate    : Date             = Date()
        let expiry        : StorehouseExpiry = .date(expiryDate)
        let memory        : Int              = 100_000_000
        let afterPurge    : Int              = 60_000_000
        
        let configuration = StorehouseConfigurationAutoPurging(expiry: expiry, memory: memory, preferredMemoryUsageAfterPurge: afterPurge)
        let transformer   = WarehouseTransformerFactory.forCodable(ofType: String.self)
        
        let uninitializedSut = StorehouseAutoPurging(configuration: configuration, transformer: transformer)
        
        // Then
        XCTAssertEqual(uninitializedSut.memoryCapacity, memory, "initialized value should be equal to expected value")
        XCTAssertEqual(uninitializedSut.preferredMemoryUsageAfterPurge, afterPurge, "initialized value should be equal to expected value")
    }
    
    // MARK: - vars
    func test_vars_currentDiskUsage_shouldReturnExpectedValue() {
        
        // Given
        let objectToSave1       = "objectToSave1"
        let savedObjectKey1     = "key1"
        let objectToSave2       = "objectToSave2"
        let savedObjectKey2     = "key2"
        let expectedMemoryUsage = 52
        
        // When
        try? sut.setObject(objectToSave1, forKey: savedObjectKey1, expiry: expireNow)
        try? sut.setObject(objectToSave2, forKey: savedObjectKey2, expiry: expireNow)
        let currentMemoryUsage = sut.currentMemoryUsage
        
        // Then
        XCTAssertEqual(currentMemoryUsage, expectedMemoryUsage, "entered strings should use expected disk space")
    }

    // MARK: - funcs
    func test_funcs_emptyEntry_shouldReturnNil() {
        
        let entry = try? sut.entry(forKey: "key")
        
        // Then
        XCTAssertNil(entry, "uninserted value should be nil")
    }
    func test_funcs_setObjectAndEntry_objectShouldBeSet() {
        
        // Given
        let objectToSave   = "objectToSave"
        let savedObjectKey = "key"
        
        // When
        try? sut.setObject(objectToSave, forKey: savedObjectKey, expiry: expireNow)
        let entry = try? sut.entry(forKey: savedObjectKey).object
        
        // Then
        XCTAssertEqual(entry, objectToSave, "object should be set")
    }
    func test_funcs_removeAll_shouldReturnNil() {
        
        // Given
        let objectToSave   = "objectToSave"
        let savedObjectKey = "key"
        
        // When
        try? sut.setObject(objectToSave, forKey: savedObjectKey, expiry: expireNow)
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
        try? sut.setObject(objectToSave, forKey: savedObjectKey, expiry: expireNow)
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
        try? sut.setObject(objectToSave, forKey: savedObjectKey, expiry: expireNow)
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
        try? sut.setObject(objectToSave1, forKey: savedObjectKey1, expiry: expireNow)
        try? sut.setObject(objectToSave2, forKey: savedObjectKey2, expiry: expireNow)
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
        try? sut.setObject(objectToSave1, forKey: savedObjectKey1, expiry: expireNow)
        try? sut.setObject(objectToSave2, forKey: savedObjectKey2, expiry: expireNow)
        try? sut.removeStoredObjects(since: Date())
        
        let entry1 = try? sut.entry(forKey: savedObjectKey1).object
        let entry2 = try? sut.entry(forKey: savedObjectKey2).object
        
        // Then
        XCTAssertNil(entry1, "removed value should be nil")
        XCTAssertNil(entry2, "removed value should be nil")
    }
    func test_funcs_autoRemoveObjects_shouldRemoveObjectAutomatically() {
        
        // Given
        let expiryDate    : Date             = Date()
        let expiry        : StorehouseExpiry = .date(expiryDate)
        let memory        : Int              = 50
        let afterPurge    : Int              = 27
        
        let configuration = StorehouseConfigurationAutoPurging(expiry: expiry, memory: memory, preferredMemoryUsageAfterPurge: afterPurge)
        let transformer   = WarehouseTransformerFactory.forCodable(ofType: String.self)
        
        let lowMemorySut = StorehouseAutoPurging(configuration: configuration, transformer: transformer)
        
        let objectToSave1   = "objectToSave1"
        let savedObjectKey1 = "key1"
        let objectToSave2   = "objectToSave2"
        let savedObjectKey2 = "key2"
        
        // When
        try? lowMemorySut.setObject(objectToSave1, forKey: savedObjectKey1, expiry: expireNow)
        try? lowMemorySut.setObject(objectToSave2, forKey: savedObjectKey2, expiry: expireNow)
        
        // Then
        XCTAssertEqual(lowMemorySut.currentMemoryUsage, 26, "auto purge should only purge the first object")
    }
}
