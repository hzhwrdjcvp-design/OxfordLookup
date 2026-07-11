//
//  OxfordLookupTests.swift
//  OxfordLookupTests
//
//  Created by Khan on 7/11/26.
//

import Foundation
import Testing

struct OxfordLookupTests {
    @Test func trimsLeadingAndTrailingWhitespace() {
        #expect(OxfordLookupURLBuilder.normalizedTerm(from: "  scalper\n") == "scalper")
    }

    @Test func removesSurroundingPunctuation() {
        #expect(OxfordLookupURLBuilder.normalizedTerm(from: "“Scalper!”") == "scalper")
    }

    @Test func lowercasesCapitalization() {
        #expect(OxfordLookupURLBuilder.normalizedTerm(from: "ScAlPeR") == "scalper")
    }

    @Test func preservesInternalHyphens() {
        #expect(OxfordLookupURLBuilder.normalizedTerm(from: "Well-known") == "well-known")
    }

    @Test func preservesInternalApostrophes() {
        #expect(OxfordLookupURLBuilder.normalizedTerm(from: "can't") == "can't")
    }

    @Test func emptyInputHasNoURLs() {
        #expect(OxfordLookupURLBuilder.normalizedTerm(from: "  !!!  ") == "")
        #expect(OxfordLookupURLBuilder.directDefinitionURL(for: "  !!!  ") == nil)
        #expect(OxfordLookupURLBuilder.fallbackSearchURL(for: "  !!!  ") == nil)
    }

    @Test func scalperDirectURL() throws {
        let url = try #require(OxfordLookupURLBuilder.directDefinitionURL(for: "scalper"))
        #expect(url.absoluteString == "https://www.oxfordlearnersdictionaries.com/definition/english/scalper")
    }

    @Test func multiwordPhraseFallbackSearchURL() throws {
        let url = try #require(OxfordLookupURLBuilder.fallbackSearchURL(for: "look up"))
        #expect(url.absoluteString == "https://www.oxfordlearnersdictionaries.com/search/english/?q=look%20up")
    }
}
