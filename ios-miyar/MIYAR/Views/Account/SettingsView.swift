import SwiftUI

/// Preferences, sync status, support and the legal library.
struct SettingsView: View {
    @Environment(AppStore.self) private var store

    @State private var showSupport = false
    @State private var showHelp = false

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: S.settingsLegal(language)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(S.language(language)).miyarSectionHeader()
                        HStack {
                            Text(language.displayName)
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            LanguageToggle()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.notificationsSetting(language)).miyarSectionHeader()
                        NavigationLink(value: AppRoute.notifications) {
                            MiyarRowLabel(
                                symbol: "bell",
                                title: S.notifications(language),
                                trailingText: store.unreadNotifications > 0 ? "\(store.unreadNotifications)" : nil
                            )
                        }
                        .buttonStyle(.plain)
                        MiyarDivider()
                        MiyarRow(symbol: "trash", title: S.markAllRead(language), showsChevron: false) {
                            store.markNotificationsRead()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(S.syncStatus(language)).miyarSectionHeader()
                        HStack(spacing: 8) {
                            Circle().fill(Theme.gold).frame(width: 8, height: 8)
                            Text(S.localOnly(language))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.ink)
                            Spacer(minLength: 0)
                            if let sync = store.ifraLastSync {
                                Text(sync.shortDate(language))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                        }
                        Text(S.backendLocalNotice(language))
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.ifra(language)).miyarSectionHeader()
                        NavigationLink(value: AppRoute.ifra) {
                            MiyarRowLabel(symbol: "checkmark.shield", title: S.ifraSection(language), subtitle: S.ifraDisclaimer(language))
                        }
                        .buttonStyle(.plain)
                        MiyarDivider()
                        Link(destination: URL(string: IFRAInfo.materialsSearch) ?? URL(string: IFRAInfo.officialHome)!) {
                            MiyarRowLabel(symbol: "safari", title: S.ifraOfficialSearch(language))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.helpCenter(language)).miyarSectionHeader()
                        MiyarRow(symbol: "questionmark.circle", title: S.helpCenter(language)) { showHelp = true }
                        MiyarDivider()
                        MiyarRow(symbol: "envelope", title: S.contactSupport(language)) { showSupport = true }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.termsConditions(language)).miyarSectionHeader()
                        ForEach(LegalDoc.allCases) { doc in
                            NavigationLink(value: AppRoute.legal(doc)) {
                                MiyarRowLabel(symbol: doc.symbol, title: doc.title(language))
                            }
                            .buttonStyle(.plain)
                            if doc != LegalDoc.allCases.last { MiyarDivider() }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    NavigationLink(value: AppRoute.security) {
                        MiyarRowLabel(
                            symbol: "lock.shield",
                            title: S.security(language),
                            subtitle: S.deleteAccountHint(language)
                        )
                        .miyarCard(padding: 16)
                    }
                    .buttonStyle(.plain)
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
        .sheet(isPresented: $showHelp) {
            InfoSheet(title: S.helpCenter(language), body: LegalCopy.help)
        }
        .sheet(isPresented: $showSupport) {
            InfoSheet(title: S.contactSupport(language), body: LegalCopy.support)
        }
    }
}

/// Small read-only sheet used for help and support copy.
struct InfoSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let title: String
    let body_: LText

    init(title: String, body: LText) {
        self.title = title
        self.body_ = body
    }

    var body: some View {
        let language = store.language
        NavigationStack {
            ScrollView {
                Text(body_(language))
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)
                    .padding(Theme.margin)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.close(language)) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationContentInteraction(.scrolls)
        .environment(\.layoutDirection, language.layoutDirection)
    }
}

// MARK: - Legal documents

/// Renders a policy document in the reader's language.
struct LegalDocumentView: View {
    @Environment(AppStore.self) private var store
    let doc: LegalDoc

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: doc.title(language)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(doc.title(language))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(LegalCopy.updated(language))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)

                    ForEach(Array(LegalCopy.sections(for: doc).enumerated()), id: \.offset) { _, section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.heading(language))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            Text(section.body(language))
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.ink.opacity(0.82))
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .miyarCard(padding: 16)
                    }

                    if doc == .market || doc == .refund {
                        MiyarBanner(text: S.guidelinesReminder(language), tone: .info)
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
    }
}

/// A heading + body pair inside a policy document.
nonisolated struct LegalSection: Sendable {
    let heading: LText
    let body: LText
}

/// The written policies shown in the legal library.
nonisolated enum LegalCopy {
    static let updated = LText("آخر تحديث: يناير ٢٠٢٦", "Last updated: January 2026")

    static let help = LText(
        """
        ابدأ من الحاسبة لإنشاء تركيبة: حدّد حجم القارورة ونسبة الزيت، ثم أضف المواد من المكتبة.
        تعرض شاشة النتائج المقادير بالمل والغرام والقطرات مع تفصيل التكلفة.
        قسم سلامة IFRA يعرض القيود المعروفة فقط، ويظهر «الحد الرسمي غير مُتحقق منه» عند غياب رقم موثّق.
        في السوق يمكنك النشر للبيع أو التبادل، وإرسال عروض تبادل من مجموعتك.
        المجتمع للنقاش والأسئلة، والرسائل الخاصة للتواصل المباشر مع الأعضاء والبائعين.
        """,
        """
        Start in the calculator: set the bottle size and oil percentage, then add materials from the library.
        The results screen shows quantities in millilitres, grams and drops with a full cost breakdown.
        The IFRA section shows known restrictions only, and displays "Official limit not verified" when no confirmed figure exists.
        In the marketplace you can list for sale or exchange, and send exchange offers from your collection.
        The community is for discussion and questions; private messages connect you directly with members and sellers.
        """
    )

    static let support = LText(
        """
        للتواصل مع فريق الدعم اكتب إلينا على support@miyar.app مع وصف المشكلة ولقطة شاشة إن أمكن.
        نرد عادة خلال يوم عمل واحد. لبلاغات السوق أو المحتوى استخدم زر «إبلاغ» داخل الإعلان أو المنشور ليصل البلاغ للمشرفين مباشرة.
        """,
        """
        Contact the support team at support@miyar.app with a description of the issue and a screenshot when possible.
        We usually reply within one business day. For marketplace or content reports, use the Report button inside the listing or post so moderators receive it directly.
        """
    )

    static func sections(for doc: LegalDoc) -> [LegalSection] {
        switch doc {
        case .terms: terms
        case .privacy: privacy
        case .community: community
        case .market: market
        case .refund: refund
        }
    }

    private static let terms: [LegalSection] = [
        LegalSection(
            heading: LText("قبول الشروط", "Acceptance of terms"),
            body: LText(
                "باستخدامك تطبيق معيار فإنك توافق على هذه الشروط. التطبيق أداة تعليمية وحسابية لمصممي العطور والهواة، ولا يقدّم استشارة تنظيمية أو طبية.",
                "By using MIYAR you agree to these terms. The app is an educational and calculation tool for perfume designers and hobbyists, and does not provide regulatory or medical advice."
            )
        ),
        LegalSection(
            heading: LText("الحساب والمسؤولية", "Your account"),
            body: LText(
                "أنت مسؤول عن دقة بيانات حسابك وسرية كلمة المرور، وعن كل نشاط يتم عبر حسابك. يمكنك حذف حسابك في أي وقت من شاشة الأمان.",
                "You are responsible for the accuracy of your account details, the confidentiality of your password and all activity under your account. You may delete your account at any time from the security screen."
            )
        ),
        LegalSection(
            heading: LText("المحتوى والملكية", "Content and ownership"),
            body: LText(
                "تركيباتك وملاحظاتك ملك لك. بنشرك محتوى في المجتمع أو السوق تمنح التطبيق إذنًا بعرضه للأعضاء الآخرين داخل التطبيق فقط.",
                "Your formulas and notes belong to you. By publishing content in the community or marketplace you grant the app permission to display it to other members inside the app only."
            )
        ),
        LegalSection(
            heading: LText("حدود المسؤولية", "Limitation of liability"),
            body: LText(
                "النتائج والحسابات إرشادية. لا يتحمل التطبيق مسؤولية أي ضرر ناتج عن تصنيع أو استخدام تركيبة، ويبقى تقييم السلامة مسؤولية المستخدم ومختص مؤهل.",
                "Results and calculations are indicative. The app is not liable for any harm arising from producing or using a formula; safety assessment remains the responsibility of the user and a qualified specialist."
            )
        )
    ]

    private static let privacy: [LegalSection] = [
        LegalSection(
            heading: LText("البيانات التي نجمعها", "Data we collect"),
            body: LText(
                "الاسم والبريد الإلكتروني ومحتوى ملفك، إضافة إلى ما تنشئه داخل التطبيق: التركيبات، الإعلانات، المنشورات، الرسائل والمفضلات.",
                "Your name, email and profile details, plus what you create in the app: formulas, listings, posts, messages and favourites."
            )
        ),
        LegalSection(
            heading: LText("أين تُحفظ بياناتك", "Where your data lives"),
            body: LText(
                "تُحفظ بياناتك حاليًا في تخزين محلي آمن داخل جهازك. عند تفعيل المزامنة السحابية ستُحفظ في قاعدة بيانات محمية بسياسات وصول على مستوى الصف، بحيث لا يقرأ أحد بياناتك سواك.",
                "Your data is currently stored in secure on-device storage. When cloud sync is enabled it moves to a protected database with row-level access policies, so nobody but you can read your records."
            )
        ),
        LegalSection(
            heading: LText("كلمات المرور", "Passwords"),
            body: LText(
                "لا تُخزَّن كلمات المرور كنص صريح؛ تُحفظ بصمة تشفيرية فقط، ولا يمكن استرجاع كلمة المرور الأصلية منها.",
                "Passwords are never stored in plain text; only a cryptographic hash is kept, and the original password cannot be recovered from it."
            )
        ),
        LegalSection(
            heading: LText("مساعد الذكاء الاصطناعي", "AI assistant"),
            body: LText(
                "تُرسل أسئلتك إلى خادم وسيط آمن، ولا يحتوي التطبيق على أي مفتاح سري. لا تُستخدم محادثاتك للتعريف بك، ويمكنك حذف أي محادثة في أي وقت.",
                "Your questions are sent through a secure server proxy; the app contains no secret keys. Conversations are not used to identify you and you can delete any chat at any time."
            )
        ),
        LegalSection(
            heading: LText("حقوقك", "Your rights"),
            body: LText(
                "يمكنك تعديل بياناتك أو حذف حسابك نهائيًا من شاشة الأمان. الحذف يزيل ملفك وتركيباتك وإعلاناتك ومنشوراتك ورسائلك.",
                "You can edit your data or permanently delete your account from the security screen. Deletion removes your profile, formulas, listings, posts and messages."
            )
        )
    ]

    private static let community: [LegalSection] = [
        LegalSection(
            heading: LText("الاحترام أولًا", "Respect first"),
            body: LText(
                "تعامل مع الأعضاء باحترام. لا مكان للإساءة أو التمييز أو المضايقة أو التشهير.",
                "Treat members with respect. Abuse, discrimination, harassment and defamation are not allowed."
            )
        ),
        LegalSection(
            heading: LText("دقّة المعلومة", "Accuracy"),
            body: LText(
                "عند مشاركة تركيبة أو نصيحة، وضّح أنها تجربتك الشخصية. لا تنشر أرقام حدود IFRA على أنها رسمية دون مصدر موثّق.",
                "When sharing a formula or advice, make clear it is your own experience. Do not present IFRA limit figures as official without a verified source."
            )
        ),
        LegalSection(
            heading: LText("الإبلاغ والحظر", "Reporting and blocking"),
            body: LText(
                "استخدم زر «إبلاغ» للمحتوى المخالف، وزر «حظر» لإيقاف التواصل مع أي عضو. تُراجع البلاغات من فريق الإشراف.",
                "Use Report for content that breaks the rules and Block to stop contact with a member. Reports are reviewed by the moderation team."
            )
        )
    ]

    private static let market: [LegalSection] = [
        LegalSection(
            heading: LText("وصف صادق", "Honest descriptions"),
            body: LText(
                "اذكر الحجم والكمية المتبقية والحالة بدقة، وأضف صورًا حقيقية للمنتج نفسه. المنتجات المقلّدة ممنوعة تمامًا.",
                "State the size, remaining amount and condition accurately, and add real photos of the actual item. Counterfeit products are strictly prohibited."
            )
        ),
        LegalSection(
            heading: LText("التبادل والتسليم", "Exchange and delivery"),
            body: LText(
                "اتفق مع الطرف الآخر على طريقة التسليم قبل الشحن. التطبيق يوفّر مساحة للتواصل ولا يكون طرفًا في الصفقة.",
                "Agree the delivery method with the other party before shipping. The app provides a space to communicate and is not a party to the transaction."
            )
        ),
        LegalSection(
            heading: LText("المواد المقيّدة", "Restricted materials"),
            body: LText(
                "لا تعرض موادًا محظورة أو خاضعة لقيود دون توثيق. يبقى الالتزام بالأنظمة المحلية ومعايير IFRA مسؤولية البائع.",
                "Do not list prohibited or restricted materials without documentation. Compliance with local regulations and IFRA standards remains the seller's responsibility."
            )
        )
    ]

    private static let refund: [LegalSection] = [
        LegalSection(
            heading: LText("بين الأعضاء", "Between members"),
            body: LText(
                "الاسترداد في صفقات السوق يتم بالاتفاق بين البائع والمشتري. ننصح بتوثيق الحالة بالصور قبل الشحن وبعد الاستلام.",
                "Refunds in marketplace transactions are agreed between buyer and seller. We recommend documenting condition with photos before shipping and on arrival."
            )
        ),
        LegalSection(
            heading: LText("المشتريات داخل التطبيق", "In-app purchases"),
            body: LText(
                "الاشتراكات وفصول الكتاب المميّزة تُدار عبر متجر التطبيقات، وتخضع سياسة استردادها لشروط المتجر.",
                "Subscriptions and premium book chapters are handled by the app store, and their refunds follow the store's policy."
            )
        )
    ]
}
