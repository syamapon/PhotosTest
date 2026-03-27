import SwiftUI
import AppKit

struct DoubleClickCapture<Content: View>: NSViewRepresentable {
    let content: Content
    let onDoubleClick: (CGPoint) -> Void

    init(@ViewBuilder content: () -> Content, onDoubleClick: @escaping (CGPoint) -> Void) {
        self.content = content()
        self.onDoubleClick = onDoubleClick
    }

    func makeNSView(context: Context) -> NSHostingView<Content> {
        let view = NSHostingView(rootView: content)
        let recognizer = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick(_:)))
        recognizer.numberOfClicksRequired = 2
        view.addGestureRecognizer(recognizer)
        return view
    }

    func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
        nsView.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDoubleClick: onDoubleClick)
    }

    final class Coordinator: NSObject {
        let onDoubleClick: (CGPoint) -> Void
        init(onDoubleClick: @escaping (CGPoint) -> Void) {
            self.onDoubleClick = onDoubleClick
        }

        @objc func handleClick(_ sender: NSClickGestureRecognizer) {
            guard let view = sender.view else { return }
            // view のローカル座標系での位置
            let point = sender.location(in: view)
            onDoubleClick(point)
        }
    }
}
