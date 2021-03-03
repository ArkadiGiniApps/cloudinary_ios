//
//  DownloaderAssetTests.swift
//
//  Copyright (c) 2021 Cloudinary (http://cloudinary.com)
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

import XCTest
import Cloudinary
@testable import Cloudinary

// MARK: - assets
class DownloaderAssetTests: NetworkBaseTest {
    
    var sut: CLDDownloader!
    
    override func setUp() {
        super.setUp()
        
        sut = cloudinary!.createDownloader()
    }
    
    override func tearDown() {
        
        sut.downloadCoordinator.urlCache.removeAllCachedResponses()
        sut = nil
        super.tearDown()
    }
    
    static var skipableTests = [
        ("test_downloadAsset_pdf_shouldDownloadWithoutCaching", test_downloadAsset_pdf_shouldDownloadWithoutCaching),
    ]
        
    override func shouldSkipTest() -> Bool {
        
        if super.shouldSkipTest() {
            return true
        }
        if ProcessInfo.processInfo.arguments.contains("TEST_PDF") {
            return false
        }
        if let privateName = testRun?.test.name {
            if !DownloaderAssetTests.skipableTests.filter({
                return privateName.contains($0.0)
            }).isEmpty {
                return true
            }
        }
        return false
    }
    
    func test_downloadAsset_image_shouldDownloadWithoutCaching() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        // Given
        var expectation = self.expectation(description: "Upload should succeed")
        let resource: TestResourceType = .borderCollie
        var publicId: String?
        
        // When
        /// upload file to get publicId
        uploadFile(resource).response({ (result, error) in
            XCTAssertNil(error)
            publicId = result?.publicId
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        guard let pubId = publicId else {
            XCTFail("Public ID should not be nil at this point")
            return
        }
        
        expectation = self.expectation(description: "test_downloadAsset_asset_shouldDownloadAssetAsData Download asset should succeed")
        
        var response: Data?
        /// download asset by publicId - first time, no cache yet
        let url = cloudinary!.createUrl().generate(pubId)
        
        sut.fetchAsset(url!).responseAsset { (responseData, err) in
            response = responseData
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Then
        XCTAssertEqual(response,resource.data, "uploaded data should be equal to downloaded data")
        XCTAssertThrowsError(try sut.downloadCoordinator.urlCache.warehouse.entry(forKey: url!), "images should not be cached (we exclude them, users should use fetchImage)")
    }
    func test_downloadAsset_video_shouldDownloadAndCacheVideo() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        // Given
        let resource: TestResourceType = .dog2
        var publicId: String?
        var expectation = self.expectation(description: "Upload should succeed")
        
        let params = CLDUploadRequestParams()
        params.setResourceType(.video)
        
        // When
        uploadFile(resource, params: params).response({ (result, error) in
            publicId = result?.publicId
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: longTimeout, handler: nil)
        
        guard let pubId = publicId else {
            XCTFail("Public ID should not be nil at this point")
            return
        }
        
        expectation = self.expectation(description: "test_downloadAsset_video_shouldDownloadAssetAsData Download should succeed")
        
        var response: Data?
        
        /// download asset by publicId
        let url = cloudinary!.createUrl().setResourceType(.video).generate(pubId)
        sut.fetchAsset(url!).responseAsset { (responseData, err) in
            response = responseData
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Then
        XCTAssertEqual(response, resource.data, "uploaded data should be equal to downloaded data")
        XCTAssertNotNil(try sut.downloadCoordinator.urlCache.warehouse.entry(forKey: url!), "response should be cached")
    }
    func test_downloadAsset_pdf_shouldDownloadWithoutCaching() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        // Given
        var expectation = self.expectation(description: "Upload should succeed")
        let resource: TestResourceType = .pdf
        var publicId: String?
        
        // When
        /// upload file to get publicId
        uploadFile(resource).response({ (result, error) in
            XCTAssertNil(error)
            publicId = result?.publicId
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        guard let pubId = publicId else {
            XCTFail("Public ID should not be nil at this point")
            return
        }
        
        expectation = self.expectation(description: "test_downloadAsset_asset_shouldDownloadAssetAsData Download asset should succeed")
        
        var response: Data?
        /// download asset by publicId - first time, no cache yet
        let url = cloudinary!.createUrl().generate(pubId)
        
        sut.fetchAsset(url!).responseAsset { (responseData, err) in
            response = responseData
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Then
        XCTAssertEqual(response,resource.data, "uploaded data should be equal to downloaded data")
        XCTAssertNotNil(try sut.downloadCoordinator.urlCache.warehouse.entry(forKey: url!), "response should be cached")
    }
    func test_downloadAsset_docx_shouldDownloadWithoutCaching() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        // Given
        var expectation = self.expectation(description: "Upload should succeed")
        let resource: TestResourceType = .docx
        var publicId: String?
        
        let params = CLDUploadRequestParams()
        params.setResourceType(.raw)
        // When
        /// upload file to get publicId
        uploadFile(resource, params: params).response({ (result, error) in
            XCTAssertNil(error)
            publicId = result?.publicId
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        guard let pubId = publicId else {
            XCTFail("Public ID should not be nil at this point")
            return
        }
        
        expectation = self.expectation(description: "test_downloadAsset_asset_shouldDownloadAssetAsData Download asset should succeed")
        
        var response: Data?
        /// download asset by publicId - first time, no cache yet
        let url = cloudinary!.createUrl().setResourceType(.raw).generate(pubId)
        sut.fetchAsset(url!).responseAsset { (responseData, err) in
            response = responseData
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Then
        XCTAssertEqual(response,resource.data, "uploaded data should be equal to downloaded data")
        XCTAssertNotNil(try sut.downloadCoordinator.urlCache.warehouse.entry(forKey: url!), "response should be cached")
    }
    
    func test_downloadAsset_videoWithoutCache_shouldDownloadWithoutCaching() {
        
        XCTAssertNotNil(cloudinary!.config.apiSecret, "Must set api secret for this test")
        
        cloudinary!.cacheAssetMaxMemoryTotalCost = 20
        cloudinary!.cacheAssetMaxDiskCapacity    = 20
        
        // Given
        let resource: TestResourceType = .dog2
        var publicId: String?
        var expectation = self.expectation(description: "Upload should succeed")
        
        let params = CLDUploadRequestParams()
        params.setResourceType(.video)
        
        // When
        uploadFile(resource, params: params).response({ (result, error) in
            publicId = result?.publicId
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: longTimeout, handler: nil)
        
        guard let pubId = publicId else {
            XCTFail("Public ID should not be nil at this point")
            return
        }
        
        expectation = self.expectation(description: "test_downloadAsset_video_shouldDownloadAssetAsData Download should succeed")
        
        var response: Data?
        
        /// download asset by publicId
        let url = cloudinary!.createUrl().setResourceType(.video).generate(pubId)
        sut.fetchAsset(url!).responseAsset { (responseData, err) in
            response = responseData
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Then
        XCTAssertEqual(response, resource.data, "uploaded data should be equal to downloaded data")
        XCTAssertThrowsError(try sut.downloadCoordinator.urlCache.warehouse.entry(forKey: url!), "response should be cached")
    }
}
