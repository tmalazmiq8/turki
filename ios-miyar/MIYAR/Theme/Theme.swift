import SwiftUI

/// Central visual identity for MIYAR — warm ivory canvas, white surfaces,
/// deep ink text and a single gold accent. Never introduce new hues.
enum Theme {
    static let canvas = Color(red: 0.969, green: 0.953, blue: 0.922)
    static let surface = Color.white
    static let ink = Color(red: 0.173, green: 0.165, blue: 0.149)
    static let gold = Color(red: 0.788, green: 0.635, blue: 0.294)
    static let goldSoft = Color(red: 0.788, green: 0.635, blue: 0.294).opacity(0.14)
    static let secondaryText = Color(red: 0.541, green: 0.514, blue: 0.471)
    static let hairline = Color(red: 0.173, green: 0.165, blue: 0.149).opacity(0.09)
    static let danger = Color(red: 0.706, green: 0.275, blue: 0.184)
    static let sepia = Color(red: 0.953, green: 0.909, blue: 0.831)

    static let cardRadius: CGFloat = 18
    static let tileRadius: CGFloat = 14
    static let margin: CGFloat = 16
}

extension Font {
    /// Display numerals: light weight, generous size.
    static func miyarDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .default)
    }

    /// Monospaced digits for prices, drops and millilitres.
    static func miyarMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

extension View {
    /// Elevated white card on the ivory canvas — hairline border, no heavy shadow.
    func miyarCard(padding: CGFloat = 16, radius: CGFloat = Theme.cardRadius) -> some View {
        self
            .padding(padding)
            .background(Theme.surface, in: .rect(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
    }

    /// Section header treatment: small, wide-tracked, secondary.
    func miyarSectionHeader() -> some View {
        self
            .font(.system(size: 12, weight: .semibold))
            .tracking(1.4)
            .foregroundStyle(Theme.secondaryText)
            .textCase(.uppercase)
    }
}

/// Primary gold action button used for every confirming action.
struct GoldButtonStyle: ButtonStyle {
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 50)
            .padding(.horizontal, fullWidth ? 0 : 22)
            .background(Theme.gold, in: .rect(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.82 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Secondary ink-outlined button.
struct InkButtonStyle: ButtonStyle {
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 50)
            .padding(.horizontal, fullWidth ? 0 : 20)
            .background(Theme.surface, in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Theme.ink.opacity(0.25), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
