import Foundation

/// Generic demo listings shown until real listings load from the database.
nonisolated enum SeedMarket {
    static let listings: [Listing] = [
        Listing(
            titleAr: "قارورة عطر خشبي شرقي ١٠٠ مل",
            titleEn: "Woody oriental eau de parfum · 100 ml",
            category: .fullBottle,
            type: .sale,
            condition: .new,
            sizeML: 100,
            remainingPercent: 100,
            priceUSD: 185,
            locationAr: "باريس، فرنسا",
            locationEn: "Paris, France",
            deliveryOptions: [.shipping, .authenticated],
            descriptionAr: "قارورة جديدة بالكرتون الأصلي. لم تُفتح. رائحة خشبية شرقية دافئة بقاعدة عنبرية.",
            descriptionEn: "Brand new with the original box, never opened. A warm woody oriental with an amber base.",
            sellerID: "elena",
            artworkSeed: 0
        ),
        Listing(
            titleAr: "عطر عود فاخر مستعمل ٥٠ مل",
            titleEn: "Premium oud fragrance, used · 50 ml",
            category: .used,
            type: .both,
            condition: .likeNew,
            sizeML: 50,
            remainingPercent: 87,
            priceUSD: 140,
            locationAr: "الرياض، السعودية",
            locationEn: "Riyadh, Saudi Arabia",
            deliveryOptions: [.shipping, .meetup],
            descriptionAr: "استُخدمت بضع مرات فقط ومحفوظة بعيدًا عن الضوء. متاحة للبيع أو التبادل مع عطر خشبي.",
            descriptionEn: "Worn only a handful of times and stored away from light. Available for sale or exchange for a woody fragrance.",
            sellerID: "sara",
            artworkSeed: 1
        ),
        Listing(
            titleAr: "ديكانت عطر حمضي ١٠ مل",
            titleEn: "Citrus fragrance decant · 10 ml",
            category: .decant,
            type: .sale,
            condition: .new,
            sizeML: 10,
            remainingPercent: 100,
            priceUSD: 28,
            locationAr: "الدوحة، قطر",
            locationEn: "Doha, Qatar",
            deliveryOptions: [.shipping],
            descriptionAr: "ديكانت معبأ حديثًا في قارورة زجاجية مع بخاخ. مثالي للتجربة قبل شراء القارورة الكاملة.",
            descriptionEn: "Freshly filled glass decant with an atomiser. Ideal for testing before buying a full bottle.",
            sellerID: "khalid",
            artworkSeed: 2
        ),
        Listing(
            titleAr: "أبسولوت ياسمين ٥ مل",
            titleEn: "Jasmine absolute · 5 ml",
            category: .rawMaterial,
            type: .sale,
            condition: .new,
            sizeML: 5,
            remainingPercent: 100,
            priceUSD: 64,
            locationAr: "مدينة الكويت، الكويت",
            locationEn: "Kuwait City, Kuwait",
            deliveryOptions: [.shipping, .meetup],
            descriptionAr: "مادة خام لصناعة العطور مع بيانات المورد. تُستخدم بنسب منخفضة بعد التخفيف.",
            descriptionEn: "Perfumery raw material supplied with the vendor's data sheet. Use at low percentages after dilution.",
            sellerID: "mohammed",
            artworkSeed: 3
        ),
        Listing(
            titleAr: "قارورة زجاجية فارغة ٥٠ مل",
            titleEn: "Empty glass bottle · 50 ml",
            category: .emptyBottle,
            type: .exchange,
            condition: .likeNew,
            sizeML: 50,
            remainingPercent: 0,
            priceUSD: 18,
            locationAr: "دبي، الإمارات",
            locationEn: "Dubai, UAE",
            deliveryOptions: [.meetup, .shipping],
            descriptionAr: "قارورة زجاجية ثقيلة بغطاء معدني، نظيفة ومعقّمة. للتبادل مع عينات أو مواد خام.",
            descriptionEn: "Heavy glass bottle with a metal cap, cleaned and sterilised. Open to exchange for samples or raw materials.",
            sellerID: "layan",
            artworkSeed: 4
        ),
        Listing(
            titleAr: "مجموعة عينات زهرية ٥ × ٢ مل",
            titleEn: "Floral sample set · 5 × 2 ml",
            category: .sample,
            type: .sale,
            condition: .new,
            sizeML: 2,
            remainingPercent: 100,
            priceUSD: 32,
            locationAr: "الدمام، السعودية",
            locationEn: "Dammam, Saudi Arabia",
            deliveryOptions: [.shipping],
            descriptionAr: "خمس عينات زهرية مختلفة للتدريب على تمييز الروائح، مع بطاقات أسماء.",
            descriptionEn: "Five different floral samples for scent-recognition training, supplied with name cards.",
            sellerID: "noura",
            artworkSeed: 5
        ),
        Listing(
            titleAr: "زيت عطري مركّز ١٢ مل",
            titleEn: "Concentrated perfume oil · 12 ml",
            category: .oil,
            type: .both,
            condition: .new,
            sizeML: 12,
            remainingPercent: 100,
            priceUSD: 55,
            locationAr: "الرياض، السعودية",
            locationEn: "Riyadh, Saudi Arabia",
            deliveryOptions: [.shipping, .meetup],
            descriptionAr: "زيت عطري بدون كحول، ثبات عالٍ، مناسب للاستخدام المباشر أو للتخفيف.",
            descriptionEn: "Alcohol-free perfume oil with high longevity, suitable for direct use or dilution.",
            sellerID: "sara",
            artworkSeed: 6
        ),
        Listing(
            titleAr: "قارورة عطر زهري ٧٥ مل",
            titleEn: "Floral eau de parfum · 75 ml",
            category: .fullBottle,
            type: .sale,
            condition: .new,
            sizeML: 75,
            remainingPercent: 100,
            priceUSD: 120,
            locationAr: "باريس، فرنسا",
            locationEn: "Paris, France",
            deliveryOptions: [.shipping],
            descriptionAr: "عطر زهري أبيض بقلب من الياسمين والنيرولي. قارورة جديدة مغلّفة.",
            descriptionEn: "A white floral with a jasmine and neroli heart. New, still sealed.",
            sellerID: "elena",
            artworkSeed: 7
        ),
        Listing(
            titleAr: "ديكانت عطر جلدي ٥ مل",
            titleEn: "Leather fragrance decant · 5 ml",
            category: .decant,
            type: .exchange,
            condition: .likeNew,
            sizeML: 5,
            remainingPercent: 80,
            priceUSD: 22,
            locationAr: "الدوحة، قطر",
            locationEn: "Doha, Qatar",
            deliveryOptions: [.shipping],
            descriptionAr: "ديكانت جلدي مدخّن، متبقٍ ٨٠٪. للتبادل مع ديكانت خشبي أو حمضي.",
            descriptionEn: "Smoky leather decant, 80% remaining. Open to swap for a woody or citrus decant.",
            sellerID: "khalid",
            artworkSeed: 8
        ),
        Listing(
            titleAr: "صندل مخفف ١٠٪ · ١٠ مل",
            titleEn: "Sandalwood 10% dilution · 10 ml",
            category: .rawMaterial,
            type: .sale,
            condition: .new,
            sizeML: 10,
            remainingPercent: 100,
            priceUSD: 26,
            locationAr: "مدينة الكويت، الكويت",
            locationEn: "Kuwait City, Kuwait",
            deliveryOptions: [.shipping, .meetup],
            descriptionAr: "صندل مخفف جاهز للتقييم على شرائط الاختبار ضمن تدريب جان كارل.",
            descriptionEn: "Pre-diluted sandalwood ready for blotter evaluation in Jean Carles training.",
            sellerID: "mohammed",
            artworkSeed: 9
        )
    ]

    static let collection: [CollectionItem] = [
        CollectionItem(
            nameAr: "عطر حمضي أخضر ٥٠ مل",
            nameEn: "Green citrus eau de parfum · 50 ml",
            sizeML: 50,
            remainingPercent: 95,
            condition: .likeNew,
            estimatedValueUSD: 210,
            artworkSeed: 2
        ),
        CollectionItem(
            nameAr: "ديكانت عطر مسكي ١٠ مل",
            nameEn: "Musk fragrance decant · 10 ml",
            sizeML: 10,
            remainingPercent: 70,
            condition: .used,
            estimatedValueUSD: 45,
            artworkSeed: 5
        ),
        CollectionItem(
            nameAr: "زيت عود مركّز ٣ مل",
            nameEn: "Concentrated oud oil · 3 ml",
            sizeML: 3,
            remainingPercent: 100,
            condition: .new,
            estimatedValueUSD: 160,
            artworkSeed: 8
        )
    ]

    /// A pending proposal another member sent for a bottle in the user's
    /// collection, so the accept / reject / negotiate flow is live from day one.
    static let offers: [ExchangeOffer] = {
        guard let target = collection.first else { return [] }
        let created = Date().addingTimeInterval(-7_200)
        return [
            ExchangeOffer(
                listingID: target.id,
                listingTitle: LText(target.nameAr, target.nameEn),
                listingValueUSD: target.estimatedValueUSD,
                offeredItemID: UUID(),
                offeredItemName: LText("قارورة عطر خشبي شرقي ١٠٠ مل", "Woody oriental eau de parfum · 100 ml"),
                offeredItemValueUSD: 185,
                offeredItemArtworkSeed: 0,
                message: "أعجبتني قارورتك الحمضية. أعرض عليك قارورتي الخشبية الجديدة مع الكرتون الأصلي.",
                delivery: .shipping,
                status: .pending,
                createdAt: created,
                counterpartyID: "elena",
                isIncoming: true,
                history: [
                    OfferEvent(status: .pending, note: "وصل عرض تبادل جديد.", byCurrentUser: false, date: created)
                ]
            )
        ]
    }()
}
