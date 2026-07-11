//
//  OxfordLookupURLBuilder.swift
//  OxfordLookup
//
//  Shared URL construction for the app and share extension.
//

import Foundation

struct OxfordLookupURLBuilder {
    private static let oxfordHost = "www.oxfordlearnersdictionaries.com"

    static func normalizedTerm(from input: String) -> String {
        var term = input.trimmingCharacters(in: .whitespacesAndNewlines)

        while let first = term.unicodeScalars.first,
              shouldTrimBoundaryScalar(first) {
            term.removeFirst()
        }

        while let last = term.unicodeScalars.last,
              shouldTrimBoundaryScalar(last) {
            term.removeLast()
        }

        return term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func directDefinitionURL(for input: String) -> URL? {
        let term = normalizedTerm(from: input)
        guard !term.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = oxfordHost
        components.path = "/definition/english/\(term)"
        return components.url
    }

    static func fallbackSearchURL(for input: String) -> URL? {
        let term = normalizedTerm(from: input)
        guard !term.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = oxfordHost
        components.path = "/search/english/"
        components.queryItems = [URLQueryItem(name: "q", value: term)]
        return components.url
    }

    static var explanation: String {
        "Oxford Learner's Dictionaries will open on its official website."
    }

    private static func shouldTrimBoundaryScalar(_ scalar: UnicodeScalar) -> Bool {
        if CharacterSet.whitespacesAndNewlines.contains(scalar) {
            return true
        }

        if CharacterSet.alphanumerics.contains(scalar) {
            return false
        }

        return CharacterSet.punctuationCharacters.contains(scalar) || CharacterSet.symbols.contains(scalar)
    }
}
