//
//  SwiftUIView.swift
//  
//
//  Created by Shota Shimazu on 2023/08/28.
//

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct AttributedTextEditor {
    @Binding var text: NSAttributedString
}

#if os(iOS)

extension AttributedTextEditor: UIViewRepresentable {
    typealias UIViewType = UITextView

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AttributedTextEditor

        init(_ parent: AttributedTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.attributedText
        }
    }
}

#elseif os(macOS)

extension AttributedTextEditor: NSViewRepresentable {
    typealias NSViewType = NSTextView

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.textStorage?.setAttributedString(text)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: AttributedTextEditor

        init(_ parent: AttributedTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.attributedString()
        }
    }
}

#endif
