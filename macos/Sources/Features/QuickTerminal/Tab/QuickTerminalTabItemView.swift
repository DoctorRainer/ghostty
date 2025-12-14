import SwiftUI

struct QuickTerminalTabItemView: View {
    @ObservedObject var tab: QuickTerminalTab
    let isHighlighted: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    let glassNS: Namespace.ID

    @State private var isHovering = false
    @State private var isHoveringCloseButton = false

    private var glassTint: Color {
        if isHighlighted { return .white.opacity(0.1) }
        if isHovering { return .black.opacity(0.15) }
        return .black.opacity(0.03)
    }

    private var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
    }

    var body: some View {
        if #available(macOS 26.0, *) {
            GlassEffectContainer {
                HStack(spacing: Constants.horizontalSpacing) {
                    renderCloseButton()
                    renderTitle()
                }
                .frame(height: Constants.height)
                .frame(minWidth: Constants.minWidth, maxWidth: .infinity)
                .contentShape(shape)
                .glassEffect(.regular.tint(glassTint), in: shape)
                .glassEffectID(tab.id, in: glassNS)
                .onHover { isHovering = $0 }
                .onTapGesture { DispatchQueue.main.async { onSelect() } }
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                )
            }
        } else {
            HStack(spacing: Constants.horizontalSpacing) {
                renderCloseButton()
                renderTitle()
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .frame(height: Constants.height)
            .frame(minWidth: Constants.minWidth, maxWidth: .infinity)
            .contentShape(shape)
            .onHover { isHovering = $0 }
            .onTapGesture { DispatchQueue.main.async { onSelect() } }
        }
    }

    @ViewBuilder private func renderCloseButton() -> some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: Constants.closeButtonFontSize))
                .foregroundColor(isHovering ? .primary : .secondary)
                .padding(Constants.closeButtonPadding)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerSize: Constants.closeButtonCornerRadius)
                .fill(closeButtonBackgroundColor)
        )
        .onHover { isHoveringCloseButton in
            self.isHoveringCloseButton = isHoveringCloseButton
        }
        .help("Click to close this tab; Option-click to close all tabs except this one")
        .opacity(isHovering ? 1 : 0)
        .animation(.easeInOut, value: isHovering)
    }

    @ViewBuilder private func renderTitle() -> some View {
        Text(tab.title)
            .foregroundColor(isHighlighted ? .primary : .secondary)
            .lineLimit(Constants.titleLineLimit)
            .truncationMode(.tail)
            .frame(minWidth: 0, maxWidth: .infinity)
    }
    
    private var closeButtonBackgroundColor: Color {
        if isHoveringCloseButton {
            Color(NSColor.unemphasizedSelectedContentBackgroundColor)
        } else {
            backgroundColor
        }
    }
    
    private var backgroundColor: Color {
        if isHighlighted {
            Color(NSColor.unemphasizedSelectedContentBackgroundColor)
        } else if isHovering {
            Color(NSColor.underPageBackgroundColor)
        } else {
            Color(NSColor.controlBackgroundColor)
        }
    }

}

extension QuickTerminalTabItemView {
    enum Constants {
        static let minWidth: CGFloat = 80
        static let height: CGFloat = 24
        static let horizontalSpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 8
        static let closeButtonPadding: CGFloat = 2
        static let closeButtonCornerRadius: CGSize = .init(width: 4, height: 4)
        static let closeButtonFontSize: CGFloat = 10
        static let titleLineLimit: Int = 1
    }
}
