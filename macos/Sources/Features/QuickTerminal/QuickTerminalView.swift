import SwiftUI

struct QuickTerminalView: View {
    let ghostty: Ghostty.App

    var controller: QuickTerminalController
    @ObservedObject var tabManager: QuickTerminalTabManager

    var body: some View {
        VStack(spacing: 0) {
            if #available(macOS 26.0, *) {
                WindowDragBar()
            }

            if tabManager.tabs.count > 1 {
                QuickTerminalTabBarView(tabManager: tabManager)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
            }

            TerminalView(
                ghostty: ghostty,
                viewModel: controller,
                delegate: controller
            )
        }
    }
}

@available(macOS 26.0, *)
struct WindowDragBar: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(maxWidth: .infinity)
            .frame(height: 22)
            .contentShape(Rectangle())
            .gesture(WindowDragGesture())
    }
}
