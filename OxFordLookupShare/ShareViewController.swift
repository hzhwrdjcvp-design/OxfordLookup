//
//  ShareViewController.swift
//  OxFordLookupShare
//
//  Created by Khan on 7/11/26.
//

import UIKit
import UniformTypeIdentifiers
import WebKit

final class ShareViewController: UIViewController {
    private let textField = UITextField()
    private let messageLabel = UILabel()
    private let webView = WKWebView(frame: .zero)
    private let openButton = UIButton(type: .system)
    private let searchButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loadSharedText()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = "Oxford Lookup"
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center

        let toolbar = UIStackView(arrangedSubviews: [cancelButton, titleLabel, doneButton])
        toolbar.axis = .horizontal
        toolbar.alignment = .center
        toolbar.distribution = .equalCentering

        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter an English word or phrase"
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .go
        textField.addTarget(self, action: #selector(openDirectDefinition), for: .editingDidEndOnExit)

        messageLabel.text = OxfordLookupURLBuilder.explanation
        messageLabel.font = .preferredFont(forTextStyle: .footnote)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        openButton.setTitle("Open in Oxford", for: .normal)
        openButton.addTarget(self, action: #selector(openDirectDefinition), for: .touchUpInside)

        searchButton.setTitle("Oxford Search", for: .normal)
        searchButton.addTarget(self, action: #selector(openFallbackSearch), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [openButton, searchButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12

        let topStack = UIStackView(arrangedSubviews: [toolbar, textField, buttonStack, messageLabel])
        topStack.axis = .vertical
        topStack.spacing = 12
        topStack.translatesAutoresizingMaskIntoConstraints = false

        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topStack)
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            webView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 16),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadSharedText() {
        guard let provider = firstPlainTextProvider() else {
            showNoTextMessage()
            return
        }

        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] item, error in
            let text = Self.text(from: item)

            DispatchQueue.main.async {
                guard let self else { return }

                if let text, !OxfordLookupURLBuilder.normalizedTerm(from: text).isEmpty {
                    self.textField.text = text
                    self.messageLabel.text = OxfordLookupURLBuilder.explanation
                } else {
                    self.showNoTextMessage()
                }

                if error != nil, text == nil {
                    self.showNoTextMessage()
                }
            }
        }
    }

    private func firstPlainTextProvider() -> NSItemProvider? {
        let inputItems = extensionContext?.inputItems as? [NSExtensionItem] ?? []

        for inputItem in inputItems {
            let providers = inputItem.attachments ?? []
            if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
                return provider
            }
        }

        return nil
    }

    private static func text(from item: NSSecureCoding?) -> String? {
        if let text = item as? String {
            return text
        }

        if let text = item as? NSString {
            return text as String
        }

        if let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    private func showNoTextMessage() {
        messageLabel.text = "No text was provided by the host app. Type or paste a word or phrase to look it up on Oxford Learner's Dictionaries."
    }

    @objc private func openDirectDefinition() {
        loadURL(OxfordLookupURLBuilder.directDefinitionURL(for: textField.text ?? ""))
    }

    @objc private func openFallbackSearch() {
        loadURL(OxfordLookupURLBuilder.fallbackSearchURL(for: textField.text ?? ""))
    }

    private func loadURL(_ url: URL?) {
        guard let url else {
            messageLabel.text = "Enter a word or phrase to look up."
            textField.becomeFirstResponder()
            return
        }

        messageLabel.text = OxfordLookupURLBuilder.explanation
        textField.resignFirstResponder()
        webView.load(URLRequest(url: url))
    }

    @objc private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(
            domain: NSCocoaErrorDomain,
            code: NSUserCancelledError,
            userInfo: nil
        ))
    }

    @objc private func done() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
