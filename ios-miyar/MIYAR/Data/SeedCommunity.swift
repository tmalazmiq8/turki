import Foundation

/// Demo community content: feed posts, conversations and notifications.
nonisolated enum SeedCommunity {
    private static func daysAgo(_ days: Double) -> Date {
        Date().addingTimeInterval(-days * 86_400)
    }

    static let posts: [Post] = [
        Post(
            authorID: "sara",
            kind: .question,
            titleAr: "كم مدة التعتيق المناسبة لتركيبة عود وورد؟",
            titleEn: "How long should an oud and rose blend macerate?",
            bodyAr: "خلطت تركيبة قاعدتها عود مع ورد طائفي بتركيز ٢٠٪. بعد أسبوع ما زالت الرائحة حادة قليلًا. هل أنتظر أربعة أسابيع أم أن هناك حدًا يفسد بعده العطر؟",
            bodyEn: "I blended a formula with an oud base and Taif rose at 20%. After a week it still smells a little sharp. Should I wait four weeks, or is there a point after which it deteriorates?",
            families: [.oriental, .floral],
            createdAt: daysAgo(0.3),
            likeCount: 48,
            comments: [
                PostComment(
                    authorID: "mohammed",
                    bodyAr: "أربعة إلى ستة أسابيع مناسبة للعود. احفظها في مكان مظلم وبارد وحرّك القارورة كل بضعة أيام.",
                    bodyEn: "Four to six weeks suits oud. Keep it dark and cool, and swirl the bottle every few days.",
                    createdAt: daysAgo(0.2),
                    likeCount: 12
                ),
                PostComment(
                    authorID: "elena",
                    bodyAr: "جرّبي أن تسحبي عينة صغيرة كل أسبوع وتقارنيها. ستلاحظين لحظة الاستقرار بنفسك.",
                    bodyEn: "Draw a small sample each week and compare. You'll notice the moment it settles yourself.",
                    createdAt: daysAgo(0.1),
                    likeCount: 7
                )
            ],
            artworkSeed: 1
        ),
        Post(
            authorID: "mohammed",
            kind: .formula,
            titleAr: "تركيبة فوجير كلاسيكية للمبتدئين",
            titleEn: "A classic fougère formula for beginners",
            bodyAr: "هذه نقطة انطلاق ممتازة لفهم بنية الفوجير: تباين بين خزامى عشبية وقاعدة كومارين وطحلب. عدّلوا النسب حسب موادكم ولا تنسوا مراجعة قيود IFRA قبل الإنتاج.",
            bodyEn: "An excellent starting point for understanding the fougère structure: a herbal lavender against a coumarin and moss base. Adjust to your own materials, and check IFRA restrictions before production.",
            families: [.fougere, .aromatic],
            createdAt: daysAgo(1.2),
            likeCount: 126,
            comments: [
                PostComment(
                    authorID: "noura",
                    bodyAr: "جربتها بنسبة برغموت أعلى وكانت النتيجة أنعم بكثير. شكرًا للمشاركة.",
                    bodyEn: "I tried it with more bergamot and the result was much softer. Thanks for sharing.",
                    createdAt: daysAgo(1.0),
                    likeCount: 9
                )
            ],
            artworkSeed: 3,
            formulaLines: [
                LText("خزامى ٢٥٪", "Lavender 25%"),
                LText("برغموت ١٥٪", "Bergamot 15%"),
                LText("إبرة الراعي ١٠٪", "Geranium 10%"),
                LText("كومارين ٢٠٪", "Coumarin 20%"),
                LText("طحلب البلوط ١٠٪", "Oakmoss 10%"),
                LText("باتشولي ١٠٪", "Patchouli 10%"),
                LText("مسك أبيض ١٠٪", "White musk 10%")
            ]
        ),
        Post(
            authorID: "elena",
            kind: .educational,
            titleAr: "لماذا تنهار مقدمتك بعد عشر دقائق؟",
            titleEn: "Why your top notes collapse after ten minutes",
            bodyAr: "المشكلة غالبًا ليست في كمية المقدمة بل في غياب مواد وسيطة تربطها بالقلب. جرّب إضافة بتيتغرين أو هيل كجسر بين الحمضيات والزهور.",
            bodyEn: "The problem is usually not the amount of top notes but the absence of bridging materials linking them to the heart. Try petitgrain or cardamom as a bridge between citrus and florals.",
            families: [.citrus, .aromatic],
            createdAt: daysAgo(2.4),
            likeCount: 203,
            comments: [],
            artworkSeed: 6
        ),
        Post(
            authorID: "noura",
            kind: .photo,
            titleAr: "ترتيب طاولة العمل بعد شهر من الفوضى",
            titleEn: "My workbench, finally organised after a month of chaos",
            bodyAr: "رتبت المواد حسب المرحلة: مقدمة على اليمين، قلب في الوسط، قاعدة على اليسار. فرق كبير في سرعة العمل.",
            bodyEn: "I sorted materials by stage: tops on the right, hearts in the middle, bases on the left. It made a huge difference to my speed.",
            families: [.woody],
            createdAt: daysAgo(3.1),
            likeCount: 88,
            comments: [],
            artworkSeed: 9
        ),
        Post(
            authorID: "khalid",
            kind: .discussion,
            titleAr: "هل يستحق الصندل الميسوري سعره؟",
            titleEn: "Is Mysore sandalwood worth the price?",
            bodyAr: "الفرق بين الصندل الأسترالي والميسوري واضح في الحلاوة الحليبية، لكن الفارق السعري كبير جدًا. ما رأيكم عمليًا في التركيبات؟",
            bodyEn: "The difference between Australian and Mysore sandalwood is clear in the milky sweetness, but the price gap is enormous. What's your practical view in formulas?",
            families: [.woody],
            createdAt: daysAgo(4.5),
            likeCount: 61,
            comments: [
                PostComment(
                    authorID: "sara",
                    bodyAr: "أستخدم الأسترالي كأساس وأضيف قطرات من الميسوري للمسة النهائية. حل وسط اقتصادي.",
                    bodyEn: "I use Australian as the base and add drops of Mysore as a finishing touch. An economical middle ground.",
                    createdAt: daysAgo(4.2),
                    likeCount: 15
                )
            ],
            artworkSeed: 4
        )
    ]

    static let conversations: [Conversation] = [
        Conversation(
            partnerID: "elena",
            messages: [
                ChatMessage(
                    senderID: "elena",
                    bodyAr: "أهلًا! القارورة ما زالت متوفرة ويمكنني شحنها هذا الأسبوع.",
                    bodyEn: "Hello! The bottle is still available and I can ship it this week.",
                    sentAt: daysAgo(0.9)
                ),
                ChatMessage(
                    senderID: SeedPeople.currentUserID,
                    bodyAr: "ممتاز. هل الشحن موثّق مع رقم تتبع؟",
                    bodyEn: "Great. Is the shipping tracked?",
                    sentAt: daysAgo(0.8)
                ),
                ChatMessage(
                    senderID: "elena",
                    bodyAr: "نعم، شحن موثّق مع رقم تتبع وتغليف مزدوج.",
                    bodyEn: "Yes — tracked dispatch with a tracking number and double packaging.",
                    sentAt: daysAgo(0.75)
                )
            ],
            updatedAt: daysAgo(0.75)
        ),
        Conversation(
            partnerID: "mohammed",
            messages: [
                ChatMessage(
                    senderID: SeedPeople.currentUserID,
                    bodyAr: "شكرًا على تركيبة الفوجير، جربتها اليوم.",
                    bodyEn: "Thanks for the fougère formula — I tried it today.",
                    sentAt: daysAgo(2.2)
                ),
                ChatMessage(
                    senderID: "mohammed",
                    bodyAr: "بالتوفيق! أخبرني بالنتيجة بعد التعتيق.",
                    bodyEn: "Good luck! Tell me the result after maceration.",
                    sentAt: daysAgo(2.1)
                )
            ],
            updatedAt: daysAgo(2.1)
        )
    ]

    static let notifications: [AppNotification] = [
        AppNotification(
            kind: .market,
            title: LText("إعلان جديد يطابق بحثك", "A new listing matches your search"),
            body: LText("ديكانت عطر حمضي ١٠ مل نُشر قبل قليل.", "A 10 ml citrus decant was just published."),
            date: Date().addingTimeInterval(-3600)
        ),
        AppNotification(
            kind: .community,
            title: LText("تعليق جديد على منشورك", "New comment on your post"),
            body: LText("علّق محمد الأنصاري على سؤالك حول التعتيق.", "Mohammed Al-Ansari commented on your maceration question."),
            date: Date().addingTimeInterval(-7 * 3600)
        ),
        AppNotification(
            kind: .exchange,
            title: LText("رد على عرض التبادل", "Response to your exchange offer"),
            body: LText("البائع يرغب في التفاوض على الفرق.", "The seller would like to negotiate the difference."),
            date: Date().addingTimeInterval(-2 * 86_400),
            isRead: true
        )
    ]

    static let sessions: [DeviceSession] = [
        DeviceSession(
            deviceName: "iPhone",
            locationAr: "الرياض، السعودية",
            locationEn: "Riyadh, Saudi Arabia",
            lastActive: Date(),
            isCurrent: true
        ),
        DeviceSession(
            deviceName: "iPad",
            locationAr: "الرياض، السعودية",
            locationEn: "Riyadh, Saudi Arabia",
            lastActive: Date().addingTimeInterval(-4 * 86_400),
            isCurrent: false
        )
    ]
}
