import SwiftUI

/// In-app notification centre.
struct NotificationsView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let language = store.language
        MiyarScreen(title: S.notifications(language)) {
            Group {
                if store.notifications.isEmpty {
                    MiyarEmptyState(
                        symbol: "bell.slash",
                        title: S.noNotifications(language),
                        message: S.backendLocalNotice(language)
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.notifications) { item in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: item.kind.symbol)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Theme.gold)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(Theme.goldSoft))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title(language))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(Theme.ink)
                                        Text(item.body(language))
                                            .font(.system(size: 13))
                                            .foregroundStyle(Theme.secondaryText)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(item.date.relativeText(language))
                                            .font(.system(size: 11))
                                            .foregroundStyle(Theme.secondaryText.opacity(0.8))
                                    }
                                    Spacer(minLength: 0)
                                    if !item.isRead {
                                        Circle().fill(Theme.gold).frame(width: 8, height: 8).padding(.top, 6)
                                    }
                                }
                                .miyarCard(padding: 14)
                            }
                        }
                        .padding(Theme.margin)
                    }
                }
            }
        }
        .toolbar {
            if !store.notifications.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(S.markAllRead(language)) { store.markNotificationsRead() }
                        Button(S.delete(language), role: .destructive) { store.clearNotifications() }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear { store.markNotificationsRead() }
    }
}
