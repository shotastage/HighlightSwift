import SwiftUI

@available(iOS 16.1, *)
@available(tvOS 16.1, *)
public struct CodeText: View {
    @Environment(\.colorScheme)
    var colorScheme
       
    @State
    var highlightTask: Task<Void, Never>?
       
    @State
    var highlightResult: HighlightResult?
       
    @Binding
    var text: String

    let language: String?
    let styleName: HighlightStyle.Name
    let onHighlight: ((HighlightResult) -> Void)?
       
    var highlightStyle: HighlightStyle {
        HighlightStyle(
            name: styleName,
            colorScheme: colorScheme
        )
    }

    public init(_ text: Binding<String>,
                    language: String? = nil,
                    style styleName: HighlightStyle.Name = .xcode,
                    onHighlight: ((HighlightResult) -> Void)? = nil) {
        self._text = text
        self.language = language
        self.styleName = styleName
        self.onHighlight = onHighlight
    }
    
    public var body: some View {
        highlightedTextEditor
            .fontDesign(.monospaced)
            .task {
                if
                    highlightTask == nil,
                    highlightResult == nil {
                    await highlightText()
                }
            }
            .onChange(of: text) { _ in
                highlightText(styleName: styleName)
            }
            .onChange(of: styleName) { newStyleName in
                highlightText(styleName: newStyleName)
            }
            .onChange(of: colorScheme) { newColorScheme in
                highlightResult = nil
                highlightText(colorScheme: newColorScheme)
            }
    }
    
    private var highlightedTextEditor: some View {
        Group {
            if let highlightResult = highlightResult {
                AttributedTextEditor(text: .constant(NSAttributedString(highlightResult.attributed)))
                
            } else {
                Text(text) // Fallback to regular Text if no highlight result is available
            }
        }
    }
        
    private func highlightText(styleName: HighlightStyle.Name? = nil,
                               colorScheme: ColorScheme? = nil) {
        let highlightStyle = HighlightStyle(
            name: styleName ?? self.styleName,
            colorScheme: colorScheme ?? self.colorScheme
        )
        highlightTask?.cancel()
        highlightTask = Task {
            await highlightText(highlightStyle)
        }
    }
    
    private func highlightText(_ style: HighlightStyle? = nil) async {
        do {
            let result = try await Highlight.text(
                text,
                language: language,
                style: style ?? highlightStyle
            )
            await handleHighlightResult(result)
        } catch {
            print(error)
        }
    }
    
    @MainActor
    private func handleHighlightResult(_ result: HighlightResult) {
        onHighlight?(result)
        if highlightResult == nil {
            highlightResult = result
        } else {
            withAnimation {
                highlightResult = result
            }
        }
    }
}

@available(iOS 16.1, *)
@available(tvOS 16.1, *)
struct CodeText_Previews: PreviewProvider {
    static let code: String = """
    import SwiftUI

    struct SwiftUIView: View {
        var body: some View {
            Text("Hello World!")
        }
    }

    struct SwiftUIView_Previews: PreviewProvider {
        static var previews: some View {
            SwiftUIView()
        }
    }
    """
    
    @State static var sampleText = code
    
    static var previews: some View {
        CodeText($sampleText)
            .padding()
            .font(.caption2)
    }
}
