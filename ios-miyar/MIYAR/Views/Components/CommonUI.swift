import SwiftUI

// MARK: - Language switch

/// The عربي | EN switch that appears in every top bar.
struct LanguageToggle: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppLanguage.allCases, id: \.self) { option in
                Button {
                    guard store.language != option else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        store.language = option
                    }
                } label: {
                    Text(option.shortLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(store.language == option ? Theme.ink : Theme.secondaryText)
                        .frame(width: 40, height: 26)
                        .background {
                            if store.language == option {
                                Capsule().fill(Theme.gold.opacity(0.9))
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.displayName)
            }
        }
        .padding(2)
        .background(Capsule().fill(Theme.goldSoft))
        .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
    }
}

// MARK: - Bars & headers

/// Small caps section heading with an optional trailing action.
struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).miyarSectionHeader()
            Spacer(minLength: 8)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.gold)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Wordmark used on the welcome screen and the home header.
struct MiyarWordmark: View {
    var size: CGFloat = 34
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(spacing: 6) {
            Image("MiyarLogo")
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.5, height: size * 1.5)
            Text("MIYAR")
                .font(.system(size: size, weight: .light))
                .tracking(size * 0.28)
                .foregroundStyle(Theme.ink)
            Text(S.appName(.ar))
                .font(.system(size: size * 0.42, weight: .regular))
                .foregroundStyle(Theme.gold)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(S.appName(store.language))
    }
}

/// Small round logo mark for tab bars and headers where the full wordmark won't fit.
struct MiyarLogoMark: View {
    var size: CGFloat = 32

    var body: some View {
        Image("MiyarLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
    }
}

// MARK: - Inputs

/// Rounded search field on the ivory canvas.
struct MiyarSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.secondaryText)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.ink)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.close(.en))
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Theme.surface, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.hairline, lineWidth: 1))
    }
}

/// Labelled text field used across every form.
struct MiyarField: View {
    let label: String
    var placeholder: String = ""
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType?
    var lineLimit: ClosedRange<Int>?

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.secondaryText)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else if let lineLimit {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(lineLimit)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 16))
            .foregroundStyle(Theme.ink)
            .keyboardType(keyboard)
            .textContentType(contentType)
            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
            .autocorrectionDisabled(keyboard == .emailAddress)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Theme.surface, in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
        }
    }
}

/// Inline validation / info banner.
struct MiyarBanner: View {
    enum Tone { case error, info, success }

    let text: String
    var tone: Tone = .info

    private var color: Color {
        switch tone {
        case .error: Theme.danger
        case .info: Theme.secondaryText
        case .success: Theme.gold
        }
    }

    private var symbol: String {
        switch tone {
        case .error: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 13))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(tone == .error ? Theme.danger : Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(color.opacity(0.08), in: .rect(cornerRadius: 12))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Chips

/// Selectable pill used for filters, families and categories.
struct MiyarChip: View {
    let title: String
    var symbol: String?
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol).font(.system(size: 11, weight: .semibold))
                }
                Text(title).font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? Theme.ink : Theme.secondaryText)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(isSelected ? Theme.gold.opacity(0.9) : Theme.surface, in: .capsule)
            .overlay(Capsule().strokeBorder(isSelected ? Color.clear : Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

/// Read-only tag.
struct MiyarTag: View {
    let title: String
    var symbol: String?

    var body: some View {
        HStack(spacing: 5) {
            if let symbol {
                Image(systemName: symbol).font(.system(size: 10, weight: .semibold))
            }
            Text(title).font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(Theme.secondaryText)
        .padding(.horizontal, 10)
        .frame(height: 26)
        .background(Theme.goldSoft, in: .capsule)
    }
}

// MARK: - States

/// Shared empty / error state.
struct MiyarEmptyState: View {
    let symbol: String
    let title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Theme.gold)
                .frame(width: 66, height: 66)
                .background(Circle().fill(Theme.goldSoft))
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(GoldButtonStyle(fullWidth: false))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.vertical, 34)
    }
}

/// Shimmering placeholder block used while content settles.
struct SkeletonBlock: View {
    var height: CGFloat = 16
    var radius: CGFloat = 8
    @State private var shift = false

    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Theme.ink.opacity(0.06))
            .frame(height: height)
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Theme.gold.opacity(0.16), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shift ? 220 : -220)
            }
            .clipShape(.rect(cornerRadius: radius))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    shift = true
                }
            }
    }
}

// MARK: - Progress

/// Animated gold progress bar.
struct MiyarProgressBar: View {
    /// 0–1.
    let value: Double
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.ink.opacity(0.07))
                Capsule()
                    .fill(LinearGradient(colors: [Theme.gold.opacity(0.7), Theme.gold], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, min(1, value)) * proxy.size.width)
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: value)
        .accessibilityValue(Text("\(Int(value * 100))%"))
    }
}

// MARK: - Identity artwork

/// Deterministic bottle artwork for demo listings and collection items.
struct BottleArtwork: View {
    let seed: Int
    var cornerRadius: CGFloat = Theme.tileRadius

    private var palette: (Color, Color) {
        let tones: [(Color, Color)] = [
            (Color(red: 0.965, green: 0.941, blue: 0.894), Color(red: 0.831, green: 0.706, blue: 0.435)),
            (Color(red: 0.949, green: 0.933, blue: 0.906), Color(red: 0.553, green: 0.482, blue: 0.396)),
            (Color(red: 0.976, green: 0.953, blue: 0.918), Color(red: 0.741, green: 0.612, blue: 0.353)),
            (Color(red: 0.929, green: 0.918, blue: 0.898), Color(red: 0.361, green: 0.341, blue: 0.310)),
            (Color(red: 0.980, green: 0.965, blue: 0.929), Color(red: 0.788, green: 0.635, blue: 0.294))
        ]
        return tones[abs(seed) % tones.count]
    }

    var body: some View {
        let (background, accent) = palette
        ZStack {
            LinearGradient(colors: [background, background.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let bodyWidth = width * 0.42
                let bodyHeight = height * 0.5
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.14))
                        .frame(width: width * 0.85)
                        .offset(y: height * 0.22)
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(accent.opacity(0.85))
                            .frame(width: bodyWidth * 0.34, height: height * 0.07)
                        Rectangle()
                            .fill(accent.opacity(0.5))
                            .frame(width: bodyWidth * 0.22, height: height * 0.05)
                        RoundedRectangle(cornerRadius: bodyWidth * 0.18)
                            .fill(
                                LinearGradient(
                                    colors: [accent.opacity(0.42), accent.opacity(0.78)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: bodyWidth, height: bodyHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: bodyWidth * 0.18)
                                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: bodyWidth * 0.12, height: bodyHeight * 0.6)
                                    .padding(.leading, bodyWidth * 0.14)
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
        .accessibilityHidden(true)
    }
}

/// Circular member avatar built from the profile's initial.
struct AvatarCircle: View {
    let profile: UserProfile
    var size: CGFloat = 40
    @Environment(AppStore.self) private var store

    private var tone: Color {
        let tones: [Color] = [
            Theme.gold,
            Color(red: 0.553, green: 0.482, blue: 0.396),
            Color(red: 0.361, green: 0.341, blue: 0.310),
            Color(red: 0.702, green: 0.596, blue: 0.400),
            Color(red: 0.478, green: 0.435, blue: 0.373),
            Color(red: 0.831, green: 0.706, blue: 0.435),
            Color(red: 0.612, green: 0.529, blue: 0.400)
        ]
        return tones[abs(profile.avatarSeed) % tones.count]
    }

    var body: some View {
        Circle()
            .fill(tone.opacity(0.18))
            .overlay(Circle().strokeBorder(tone.opacity(0.4), lineWidth: 1))
            .overlay {
                Text(profile.initials.isEmpty ? "M" : profile.initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(Theme.ink.opacity(0.75))
            }
            .frame(width: size, height: size)
            .accessibilityLabel(profile.name(store.language))
    }
}

// MARK: - Rows

/// Standard settings / navigation row.
struct MiyarRow: View {
    let symbol: String
    let title: String
    var subtitle: String?
    var trailingText: String?
    var isDestructive: Bool = false
    var showsChevron: Bool = true
    var action: () -> Void

    @Environment(\.layoutDirection) private var direction

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isDestructive ? Theme.danger : Theme.gold)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(isDestructive ? Theme.danger.opacity(0.1) : Theme.goldSoft))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(isDestructive ? Theme.danger : Theme.ink)
                        .multilineTextAlignment(.leading)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 8)
                if let trailingText {
                    Text(trailingText)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                }
                if showsChevron {
                    Image(systemName: direction == .rightToLeft ? "chevron.left" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.secondaryText.opacity(0.6))
                }
            }
            .padding(.vertical, 11)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

/// Thin separator matching the card hairline.
struct MiyarDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
    }
}

// MARK: - Helpers

extension Double {
    /// Percentage string with at most one decimal, e.g. "22.5%".
    func percentText() -> String {
        self == rounded() ? "\(Int(self))%" : String(format: "%.1f%%", self)
    }
}

extension Date {
    /// Short relative stamp used in feeds and chats.
    func relativeText(_ language: AppLanguage) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: language.localeIdentifier)
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func shortDate(_ language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.localeIdentifier)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    func timeText(_ language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.localeIdentifier)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
