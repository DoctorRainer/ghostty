import SwiftUI

struct QuickTerminalTabBarView: View {
    @ObservedObject var tabManager: QuickTerminalTabManager

    @State private var isHoveringNewTabButton = false
    
    @Namespace private var glassNS

    private var newTabButtonBackgroundColor: Color {
        if isHoveringNewTabButton {
            Color(NSColor.underPageBackgroundColor)
        } else {
            Color(NSColor.controlBackgroundColor)
        }
    }

    var body: some View {
        if #available(macOS 26.0, *) {
            GlassEffectContainer {
                HStack(spacing: 5) {
                    renderTabBar()
                    renderAddNewTabButton()
                }
            }
            .frame(height: Constants.height)
            .background(.clear)
        } else {
            // Fallback on earlier versions
        }
    }

    @ViewBuilder private func renderTabBar() -> some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(tabManager.tabs, content: renderTabItem)
                }
                .frame(minWidth: geometry.size.width)
            }
        }
    }

    @ViewBuilder private func renderAddNewTabButton() -> some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        let tint: Color = isHoveringNewTabButton ? .black.opacity(0.3) : .black.opacity(0.4)

        let base = Image(systemName: "plus")
            .foregroundColor(Color(NSColor.secondaryLabelColor))
            .padding(.horizontal, Constants.addNewTabButtonHorizontalPadding)
            .frame(width: Constants.height, height: Constants.height)
            .contentShape(shape)
            .onHover { isHoveringNewTabButton = $0 }
            .onTapGesture { tabManager.addNewTab() }
            .help("Create a new Tab")
            .zIndex(9999)

        if #available(macOS 26.0, *) {
            base.buttonStyle(GlassButtonStyle()).glassEffect(.regular.tint(tint), in: shape)
        } else {
            base.buttonStyle(PlainButtonStyle()).background(shape.fill(newTabButtonBackgroundColor))
        }
    }

    @ViewBuilder private func renderTabItem(_ tab: QuickTerminalTab) -> some View {
        QuickTerminalTabItemView(
            tab: tab,
            isHighlighted: tabManager.currentTab?.id == tab.id,
            onSelect: { tabManager.selectTab(tab) },
            onClose: {
                if NSEvent.modifierFlags.contains(.option) {
                    tabManager.closeAllTabs(except: tab)
                } else {
                    tabManager.closeTab(tab)
                }
            },
            glassNS: glassNS
        )
        .padding(.trailing, 4) // gives the separator its own space (prevents glass bleed)
//        .overlay(alignment: .trailing) {
//            Rectangle()
//                .fill(Color(NSColor.separatorColor))
//                .frame(width: 1)
//                .padding(.vertical, 2)
//                .allowsHitTesting(false)
//                .zIndex(10) // force on top if anything overlaps
//        }
    }
}

struct QuickTerminalTabDropDelegate: DropDelegate {
    let item: QuickTerminalTab
    let tabManager: QuickTerminalTabManager
    let currentTab: QuickTerminalTab?

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        guard
            let currentTab,
            let source = tabManager.tabs.firstIndex(where: { $0.id == currentTab.id }),
            let dest = tabManager.tabs.firstIndex(where: { $0.id == item.id })
        else { return }

        if tabManager.tabs[dest].id != currentTab.id {
            let guardedDest = dest > source ? dest + 1 : dest
            tabManager.moveTab(from: IndexSet(integer: source), to: guardedDest)
        }
    }
}

extension QuickTerminalTabBarView {
    enum Constants {
        static let height: CGFloat = 24
        static let addNewTabButtonHorizontalPadding: CGFloat = 8
        static let addNewTabButtonSize: CGFloat = 50
    }
}
