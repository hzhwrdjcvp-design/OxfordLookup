//
//  ContentView.swift
//  OxfordLookup
//
//  Created by Khan on 7/11/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    @State private var lookupText = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter an English word or phrase", text: $lookupText)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        #endif
                        .onSubmit(openDirectDefinition)

                    Text(OxfordLookupURLBuilder.explanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Open in Oxford", action: openDirectDefinition)
                    Button("Oxford Search", action: openFallbackSearch)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Oxford Lookup")
        }
    }

    private func openDirectDefinition() {
        openURL(using: OxfordLookupURLBuilder.directDefinitionURL(for: lookupText))
    }

    private func openFallbackSearch() {
        openURL(using: OxfordLookupURLBuilder.fallbackSearchURL(for: lookupText))
    }

    private func openURL(using url: URL?) {
        guard let url else {
            validationMessage = "Enter a word or phrase to look up."
            return
        }

        validationMessage = nil
        openURL(url)
    }
}

#Preview {
    ContentView()
}
