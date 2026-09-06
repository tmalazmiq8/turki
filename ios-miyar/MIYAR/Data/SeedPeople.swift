import Foundation

/// Demo community members used by the marketplace and the feed.
nonisolated enum SeedPeople {
    static let currentUserID = "me"

    static let all: [UserProfile] = [
        UserProfile(
            id: "elena",
            nameAr: "إيلينا ف.",
            nameEn: "Elena V.",
            bioAr: "جامعة عطور نيتش من باريس · شحن عالمي",
            bioEn: "Niche perfume collector in Paris · ships worldwide",
            locationAr: "باريس، فرنسا",
            locationEn: "Paris, France",
            isVerified: true,
            rating: 4.9,
            salesCount: 132,
            followerCount: 2410,
            avatarSeed: 0
        ),
        UserProfile(
            id: "sara",
            nameAr: "سارة العتيبي",
            nameEn: "Sara Al-Otaibi",
            bioAr: "مهتمة بالعود والتعتيق · الرياض",
            bioEn: "Focused on oud and maceration · Riyadh",
            locationAr: "الرياض، السعودية",
            locationEn: "Riyadh, Saudi Arabia",
            isVerified: true,
            rating: 4.8,
            salesCount: 64,
            followerCount: 5820,
            avatarSeed: 1
        ),
        UserProfile(
            id: "mohammed",
            nameAr: "محمد الأنصاري",
            nameEn: "Mohammed Al-Ansari",
            bioAr: "مصمم عطور مستقل · الكويت",
            bioEn: "Independent perfume designer · Kuwait",
            locationAr: "مدينة الكويت، الكويت",
            locationEn: "Kuwait City, Kuwait",
            isVerified: true,
            rating: 4.7,
            salesCount: 41,
            followerCount: 3105,
            avatarSeed: 2
        ),
        UserProfile(
            id: "noura",
            nameAr: "نورة القحطاني",
            nameEn: "Noura Al-Qahtani",
            bioAr: "تجربة المواد الخام ومشاركة التركيبات",
            bioEn: "Experimenting with raw materials and sharing formulas",
            locationAr: "الدمام، السعودية",
            locationEn: "Dammam, Saudi Arabia",
            isVerified: false,
            rating: 4.6,
            salesCount: 18,
            followerCount: 940,
            avatarSeed: 3
        ),
        UserProfile(
            id: "layan",
            nameAr: "ليان مراد",
            nameEn: "Layan Murad",
            bioAr: "هاوية عطور ومحبة للزهور البيضاء",
            bioEn: "Perfume hobbyist, lover of white florals",
            locationAr: "دبي، الإمارات",
            locationEn: "Dubai, UAE",
            isVerified: false,
            rating: 4.5,
            salesCount: 9,
            followerCount: 412,
            avatarSeed: 4
        ),
        UserProfile(
            id: "khalid",
            nameAr: "خالد الحربي",
            nameEn: "Khalid Al-Harbi",
            bioAr: "بيع وتبادل الديكانت والعينات",
            bioEn: "Selling and swapping decants and samples",
            locationAr: "الدوحة، قطر",
            locationEn: "Doha, Qatar",
            isVerified: true,
            rating: 5.0,
            salesCount: 87,
            followerCount: 1680,
            avatarSeed: 5
        )
    ]

    static func byID(_ id: String) -> UserProfile? {
        all.first { $0.id == id }
    }

    /// The profile created for a brand-new signed-in user.
    static func newUser(name: String, email: String) -> UserProfile {
        UserProfile(
            id: currentUserID,
            nameAr: name,
            nameEn: name,
            bioAr: "",
            bioEn: "",
            locationAr: "",
            locationEn: "",
            email: email,
            isVerified: false,
            rating: 0,
            salesCount: 0,
            followerCount: 0,
            avatarSeed: 6
        )
    }
}
