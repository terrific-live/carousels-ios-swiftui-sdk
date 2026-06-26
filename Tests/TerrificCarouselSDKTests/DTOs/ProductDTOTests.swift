//
//  ProductDTOTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class ProductDTOTests: XCTestCase {

    // MARK: - Decoding: id

    func testDecode_withId_usesProvidedId() throws {
        let json = """
        { "id": "product-42" }
        """
        let product = try decode(json)
        XCTAssertEqual(product.id, "product-42")
    }

    func testDecode_withNullId_generatesUUID() throws {
        let json = """
        { "id": null }
        """
        let product = try decode(json)
        XCTAssertFalse(product.id.isEmpty)
        XCTAssertNotNil(UUID(uuidString: product.id))
    }

    func testDecode_withMissingId_generatesUUID() throws {
        let json = """
        { "name": "No ID Product" }
        """
        let product = try decode(json)
        XCTAssertFalse(product.id.isEmpty)
        XCTAssertNotNil(UUID(uuidString: product.id))
    }

    func testDecode_missingId_generatesUniqueIds() throws {
        let json = """
        { "name": "No ID" }
        """
        let product1 = try decode(json)
        let product2 = try decode(json)
        XCTAssertNotEqual(product1.id, product2.id)
    }

    // MARK: - Decoding: All Fields

    func testDecode_fullProduct_allFieldsPresent() throws {
        let json = """
        {
            "id": "p-1",
            "name": "Headphones",
            "description": "Great sound",
            "externalUrl": "https://example.com",
            "imageUrl": "https://example.com/image.jpg",
            "price": 99.99,
            "formattedPrice": "99,99 €",
            "compareAtPrice": 129.99,
            "formattedCompareAtPrice": "129,99 €",
            "currency": "EUR",
            "externalId": "ext-1",
            "sku": "SKU-001",
            "type": "custom",
            "categories": ["Audio", "Electronics"],
            "variants": [{ "id": "v-1", "name": "Black", "price": 99.99 }],
            "badge": { "color": "#FF0000", "text": "New", "textColor": "#FFFFFF" },
            "ctaButton": { "color": "#00FF00", "text": "Buy", "textColor": "#000000" },
            "background": { "color": "#333333", "textColor": "#FFFFFF" }
        }
        """
        let product = try decode(json)

        XCTAssertEqual(product.id, "p-1")
        XCTAssertEqual(product.name, "Headphones")
        XCTAssertEqual(product.description, "Great sound")
        XCTAssertEqual(product.externalUrl, "https://example.com")
        XCTAssertEqual(product.imageUrl, "https://example.com/image.jpg")
        XCTAssertEqual(product.price, 99.99)
        XCTAssertEqual(product.formattedPrice, "99,99 €")
        XCTAssertEqual(product.compareAtPrice, 129.99)
        XCTAssertEqual(product.formattedCompareAtPrice, "129,99 €")
        XCTAssertEqual(product.currency, "EUR")
        XCTAssertEqual(product.externalId, "ext-1")
        XCTAssertEqual(product.sku, "SKU-001")
        XCTAssertEqual(product.type, "custom")
        XCTAssertEqual(product.categories, ["Audio", "Electronics"])
        XCTAssertEqual(product.variants?.count, 1)
        XCTAssertEqual(product.variants?.first?.id, "v-1")
        XCTAssertEqual(product.badge?.text, "New")
        XCTAssertEqual(product.ctaButton?.text, "Buy")
        XCTAssertEqual(product.background?.color, "#333333")
    }

    func testDecode_minimalProduct_optionalsAreNil() throws {
        let json = """
        { "id": "p-min" }
        """
        let product = try decode(json)

        XCTAssertEqual(product.id, "p-min")
        XCTAssertNil(product.name)
        XCTAssertNil(product.description)
        XCTAssertNil(product.externalUrl)
        XCTAssertNil(product.imageUrl)
        XCTAssertNil(product.price)
        XCTAssertNil(product.formattedPrice)
        XCTAssertNil(product.compareAtPrice)
        XCTAssertNil(product.formattedCompareAtPrice)
        XCTAssertNil(product.currency)
        XCTAssertNil(product.externalId)
        XCTAssertNil(product.sku)
        XCTAssertNil(product.type)
        XCTAssertNil(product.categories)
        XCTAssertNil(product.variants)
        XCTAssertNil(product.badge)
        XCTAssertNil(product.ctaButton)
        XCTAssertNil(product.background)
    }

    // MARK: - Encoding Roundtrip

    func testEncodeDecode_roundtrip_preservesData() throws {
        let original = ProductDTO(
            id: "roundtrip-1",
            name: "Test",
            price: 42.0,
            formattedPrice: "42,00 €",
            badge: ProductBadgeDTO(color: "#FF0000", text: "Sale", textColor: "#FFF"),
            ctaButton: ProductCTAButtonDTO(color: "#000", text: "Buy", textColor: "#FFF")
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ProductDTO.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    // MARK: - Identifiable

    func testIdentifiable_usesIdProperty() {
        let product = ProductDTO(id: "test-id")
        // Identifiable.id should return the same value
        let identifiableId: String = product.id
        XCTAssertEqual(identifiableId, "test-id")
    }

    // MARK: - Equatable

    func testEquatable_sameData_areEqual() {
        let a = ProductDTO(id: "eq-1", name: "Same")
        let b = ProductDTO(id: "eq-1", name: "Same")
        XCTAssertEqual(a, b)
    }

    func testEquatable_differentId_areNotEqual() {
        let a = ProductDTO(id: "eq-1", name: "Same")
        let b = ProductDTO(id: "eq-2", name: "Same")
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Helpers

    private func decode(_ json: String) throws -> ProductDTO {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(ProductDTO.self, from: data)
    }
}
