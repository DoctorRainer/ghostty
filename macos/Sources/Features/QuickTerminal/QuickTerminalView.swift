import SwiftUI

struct QuickTerminalView: View {
    let ghostty: Ghostty.App

    var controller: QuickTerminalController
    @ObservedObject var tabManager: QuickTerminalTabManager

    var body: some View {
        VStack(spacing: 0) {
            if tabManager.tabs.count > 1 {
                QuickTerminalTabBarView(tabManager: tabManager)
                    .padding(.vertical, 6)
                    .background {
                        if #available(macOS 26.0, *) {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.clear)
                                .glassEffect(.clear, in: .rect(cornerRadius: 28))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
            }

            TerminalView(
                ghostty: ghostty,
                viewModel: controller,
                delegate: controller
            )
        }
    }
}
