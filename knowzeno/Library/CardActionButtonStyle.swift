//
//  CardActionButtonStyle.swift
//  knowzeno
//

import SwiftUI

struct CardActionButtonStyle: ButtonStyle {
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        CardActionButton(configuration: configuration, tint: tint)
    }
}

private struct CardActionButton: View {
    let configuration: ButtonStyle.Configuration
    let tint: Color

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .font(.callout)
            .bold()
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, 12)
            .frame(minWidth: 36, minHeight: 30)
            .background(backgroundShape)
            .overlay(borderShape)
            .clipShape(.rect(cornerRadius: 7))
            .contentShape(.rect)
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: isHovered)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
            .onHover { isHovered = $0 }
    }

    private var foregroundStyle: Color {
        guard isEnabled else { return .secondary }
        return isHovered ? tint : .secondary
    }

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(backgroundColor)
    }

    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 7)
            .stroke(borderColor, lineWidth: 1)
    }

    private var backgroundColor: Color {
        guard isEnabled else { return .clear }

        if configuration.isPressed {
            return tint.opacity(0.22)
        }

        return isHovered ? tint.opacity(0.14) : Color.secondary.opacity(0.08)
    }

    private var borderColor: Color {
        guard isEnabled else { return Color.secondary.opacity(0.12) }
        return isHovered ? tint.opacity(0.65) : Color.secondary.opacity(0.22)
    }
}
