import Foundation

/// Perfumery terminology with accurate Arabic and English wording.
nonisolated enum SeedGlossary {
    static let all: [GlossaryTerm] = [
        GlossaryTerm(
            id: "accord",
            termAr: "أكورد",
            termEn: "Accord",
            definition: LText(
                "مزيج من مادتين أو أكثر يُنتج رائحة جديدة موحّدة لا تُنسب لأي مادة بمفردها.",
                "A blend of two or more materials producing a single new smell that belongs to none of them alone."
            ),
            example: LText("أكورد الشيبر: برغموت + لادن + طحلب البلوط.", "The chypre accord: bergamot + labdanum + oakmoss."),
            category: .structure,
            related: ["pyramid", "base"]
        ),
        GlossaryTerm(
            id: "pyramid",
            termAr: "هرم العطر",
            termEn: "Fragrance pyramid",
            definition: LText(
                "تمثيل للعطر في ثلاث طبقات: المقدمة والقلب والقاعدة، مرتبة حسب سرعة التطاير.",
                "A representation of a perfume in three layers — top, heart and base — ordered by rate of evaporation."
            ),
            example: LText("مقدمة حمضية، قلب زهري، قاعدة خشبية.", "A citrus top, floral heart and woody base."),
            category: .structure,
            related: ["top", "heart", "base"]
        ),
        GlossaryTerm(
            id: "top",
            termAr: "المقدمة",
            termEn: "Top notes",
            definition: LText(
                "أول ما تشمّه من العطر، مواد سريعة التطاير تختفي عادة خلال ١٥ إلى ٣٠ دقيقة.",
                "The first impression of a perfume: highly volatile materials that usually vanish within 15 to 30 minutes."
            ),
            example: LText("البرغموت، الليمون، الهيل.", "Bergamot, lemon, cardamom."),
            category: .structure,
            related: ["pyramid", "heart"]
        ),
        GlossaryTerm(
            id: "heart",
            termAr: "القلب",
            termEn: "Heart notes",
            definition: LText(
                "جوهر العطر الذي يظهر بعد تلاشي المقدمة ويستمر عدة ساعات.",
                "The core of the perfume, appearing as the top fades and lasting several hours."
            ),
            example: LText("الياسمين، الورد، النيرولي.", "Jasmine, rose, neroli."),
            category: .structure,
            related: ["pyramid", "top", "base"]
        ),
        GlossaryTerm(
            id: "base",
            termAr: "القاعدة",
            termEn: "Base notes",
            definition: LText(
                "المواد الثقيلة بطيئة التطاير التي تمنح العطر ثباته وعمقه.",
                "Heavy, slow-evaporating materials that give the perfume its longevity and depth."
            ),
            example: LText("الصندل، العود، المسك.", "Sandalwood, oud, musk."),
            category: .structure,
            related: ["pyramid", "fixative"]
        ),
        GlossaryTerm(
            id: "sillage",
            termAr: "الأثر (سياج)",
            termEn: "Sillage",
            definition: LText(
                "الأثر العطري الذي يتركه الشخص خلفه أثناء حركته.",
                "The scented trail a wearer leaves behind while moving."
            ),
            example: LText("عطر ذو أثر قوي يُشمّ من مسافة بعيدة.", "A fragrance with strong sillage is noticed from a distance."),
            category: .technique,
            related: ["projection", "longevity"]
        ),
        GlossaryTerm(
            id: "projection",
            termAr: "الإسقاط",
            termEn: "Projection",
            definition: LText(
                "المسافة التي تنتشر إليها رائحة العطر حول مرتديه في لحظة معينة.",
                "How far a fragrance radiates around the wearer at a given moment."
            ),
            example: LText("الأمبروكسان يرفع الإسقاط بوضوح.", "Ambroxan noticeably raises projection."),
            category: .technique,
            related: ["sillage"]
        ),
        GlossaryTerm(
            id: "longevity",
            termAr: "الثبات",
            termEn: "Longevity",
            definition: LText(
                "المدة التي يبقى فيها العطر محسوسًا على الجلد.",
                "The length of time a fragrance remains perceptible on skin."
            ),
            example: LText("قاعدة غنية بالمسك تطيل الثبات.", "A musk-rich base extends longevity."),
            category: .technique,
            related: ["fixative", "base"]
        ),
        GlossaryTerm(
            id: "fixative",
            termAr: "مثبّت",
            termEn: "Fixative",
            definition: LText(
                "مادة تبطئ تطاير باقي المكونات فتطيل عمر العطر.",
                "A material that slows the evaporation of the other components, extending the perfume's life."
            ),
            example: LText("اللادن والمسك والصندل من أشهر المثبّتات.", "Labdanum, musk and sandalwood are classic fixatives."),
            category: .materials,
            related: ["base", "longevity"]
        ),
        GlossaryTerm(
            id: "maceration",
            termAr: "التعتيق (النقع)",
            termEn: "Maceration",
            definition: LText(
                "ترك التركيبة في مكان مظلم بارد لأسابيع لتندمج مكوناتها وتستقر رائحتها.",
                "Resting a finished blend in a cool dark place for weeks so the components marry and settle."
            ),
            example: LText("من أسبوعين إلى ستة أسابيع حسب التركيبة.", "Two to six weeks, depending on the formula."),
            category: .technique,
            related: ["filtration"]
        ),
        GlossaryTerm(
            id: "filtration",
            termAr: "الترشيح",
            termEn: "Filtration",
            definition: LText(
                "تصفية العطر بعد التعتيق لإزالة العوالق والحصول على سائل صافٍ.",
                "Filtering the perfume after maceration to remove particles and obtain a clear liquid."
            ),
            example: LText("يُستخدم ورق ترشيح دقيق أو مرشّح مخبري.", "A fine filter paper or laboratory filter is used."),
            category: .technique,
            related: ["maceration"]
        ),
        GlossaryTerm(
            id: "blotter",
            termAr: "شريط الاختبار",
            termEn: "Blotter / mouillette",
            definition: LText(
                "شريط ورقي ماص يُغمس في العطر لتقييم رائحته عبر الزمن.",
                "An absorbent paper strip dipped into a fragrance to evaluate it over time."
            ),
            example: LText("اكتب اسم المادة وتاريخ الغمس على الشريط.", "Write the material name and dipping date on the strip."),
            category: .technique,
            related: ["maceration"]
        ),
        GlossaryTerm(
            id: "absolute",
            termAr: "أبسولوت",
            termEn: "Absolute",
            definition: LText(
                "مستخلص عطري مركّز يُنتج بالمذيبات، أغنى وأقرب للنبتة الطبيعية من الزيت المقطّر.",
                "A highly concentrated extract obtained with solvents, richer and closer to the living plant than a distilled oil."
            ),
            example: LText("أبسولوت الياسمين، أبسولوت الورد.", "Jasmine absolute, rose absolute."),
            category: .materials,
            related: ["essentialoil", "tincture"]
        ),
        GlossaryTerm(
            id: "essentialoil",
            termAr: "زيت عطري",
            termEn: "Essential oil",
            definition: LText(
                "زيت متطاير يُستخلص بالتقطير البخاري أو العصر البارد.",
                "A volatile oil obtained by steam distillation or cold pressing."
            ),
            example: LText("زيت البرغموت يُستخرج بالعصر البارد للقشور.", "Bergamot oil is cold-pressed from the peel."),
            category: .materials,
            related: ["absolute"]
        ),
        GlossaryTerm(
            id: "tincture",
            termAr: "صبغة (تنكشر)",
            termEn: "Tincture",
            definition: LText(
                "نقع مادة خام في الكحول لفترة طويلة لاستخلاص رائحتها.",
                "A raw material steeped in alcohol over a long period to extract its scent."
            ),
            example: LText("صبغة الفانيليا أو صبغة العود.", "Vanilla tincture or oud tincture."),
            category: .materials,
            related: ["absolute", "maceration"]
        ),
        GlossaryTerm(
            id: "aldehyde",
            termAr: "ألدهيد",
            termEn: "Aldehyde",
            definition: LText(
                "مركبات قوية تمنح العطر لمعانًا صابونيًا ومساحة واسعة، تُستخدم بنسب دقيقة جدًا.",
                "Powerful compounds giving a soapy sparkle and airiness, used in very small amounts."
            ),
            example: LText("الألدهيدات هي توقيع عطور الخمسينيات الكلاسيكية.", "Aldehydes are the signature of classic 1950s perfumes."),
            category: .materials,
            related: ["accord"]
        ),
        GlossaryTerm(
            id: "chypre",
            termAr: "شيبر",
            termEn: "Chypre",
            definition: LText(
                "عائلة مبنية على تباين المقدمة الحمضية مع قاعدة من اللادن وطحلب البلوط.",
                "A family built on the contrast of a citrus top against a labdanum and oakmoss base."
            ),
            example: LText("برغموت + لادن + طحلب بلوط + باتشولي.", "Bergamot + labdanum + oakmoss + patchouli."),
            category: .families,
            related: ["fougere", "accord"]
        ),
        GlossaryTerm(
            id: "fougere",
            termAr: "فوجير",
            termEn: "Fougère",
            definition: LText(
                "عائلة تجمع الخزامى والكومارين وطحلب البلوط، وتعني «السرخس» بالفرنسية.",
                "A family combining lavender, coumarin and oakmoss; the name is French for 'fern'."
            ),
            example: LText("خزامى + كومارين + طحلب بلوط.", "Lavender + coumarin + oakmoss."),
            category: .families,
            related: ["chypre"]
        ),
        GlossaryTerm(
            id: "gourmand",
            termAr: "حلويّة (غورماند)",
            termEn: "Gourmand",
            definition: LText(
                "عائلة تستحضر روائح الطعام الحلو كالفانيليا والكراميل والكاكاو.",
                "A family evoking sweet edible smells such as vanilla, caramel and cocoa."
            ),
            example: LText("فانيليا + تونكا + كراميل.", "Vanilla + tonka + caramel."),
            category: .families,
            related: ["accord"]
        ),
        GlossaryTerm(
            id: "concentration",
            termAr: "التركيز",
            termEn: "Concentration",
            definition: LText(
                "نسبة زيت العطر إلى الكحول في القارورة، وهي ما يحدد التسمية من كولونيا إلى باروفان.",
                "The ratio of perfume oil to alcohol in the bottle, which determines the naming from cologne to parfum."
            ),
            example: LText("أو دو بارفان تتراوح عادة بين ١٥٪ و٢٠٪.", "Eau de parfum is typically between 15% and 20%."),
            category: .structure,
            related: ["dilution"]
        ),
        GlossaryTerm(
            id: "dilution",
            termAr: "التخفيف",
            termEn: "Dilution",
            definition: LText(
                "خفض تركيز مادة خام بالكحول لتسهيل تقييمها والتحكم في نسبتها.",
                "Reducing a raw material's strength with alcohol to evaluate it and control its dose."
            ),
            example: LText("تُقيَّم أغلب المواد عند تخفيف ١٠٪.", "Most materials are evaluated at a 10% dilution."),
            category: .technique,
            related: ["concentration", "blotter"]
        ),
        GlossaryTerm(
            id: "ifraterm",
            termAr: "معايير IFRA",
            termEn: "IFRA standards",
            definition: LText(
                "معايير الرابطة الدولية للمواد العطرية التي تحدد حدود استخدام المواد حسب فئة المنتج.",
                "Standards of the International Fragrance Association defining usage limits for materials by product category."
            ),
            example: LText("راجع دائمًا أحدث تعديل قبل الإنتاج.", "Always check the latest amendment before production."),
            category: .business,
            related: ["allergen"]
        ),
        GlossaryTerm(
            id: "allergen",
            termAr: "مسبب حساسية",
            termEn: "Allergen",
            definition: LText(
                "مكوّن يجب الإفصاح عنه على الملصق عند تجاوز نسبة محددة نظاميًا.",
                "A component that must be declared on the label above a regulated threshold."
            ),
            example: LText("يُذكر ضمن قائمة المكونات على العبوة.", "It is listed within the ingredient list on the packaging."),
            category: .business,
            related: ["ifraterm"]
        ),
        GlossaryTerm(
            id: "decant",
            termAr: "ديكانت",
            termEn: "Decant",
            definition: LText(
                "كمية تُنقل من قارورة أصلية إلى قارورة أصغر للتجربة أو البيع.",
                "A quantity transferred from an original bottle into a smaller one for testing or resale."
            ),
            example: LText("ديكانت ١٠ مل من قارورة ١٠٠ مل.", "A 10 ml decant from a 100 ml bottle."),
            category: .business,
            related: ["sampleterm"]
        ),
        GlossaryTerm(
            id: "sampleterm",
            termAr: "عينة",
            termEn: "Sample",
            definition: LText(
                "كمية صغيرة جدًا، غالبًا من ١ إلى ٢ مل، مخصصة للتجربة.",
                "A very small quantity, usually 1 to 2 ml, intended for trial."
            ),
            example: LText("عينة ٢ مل تكفي لعدة استخدامات.", "A 2 ml sample is enough for several wears."),
            category: .business,
            related: ["decant"]
        ),
        GlossaryTerm(
            id: "batch",
            termAr: "دفعة الإنتاج",
            termEn: "Batch",
            definition: LText(
                "رمز يشير إلى دفعة التصنيع ويُستخدم لتحديد سنة الإنتاج.",
                "A code identifying the manufacturing run, used to determine the production year."
            ),
            example: LText("يُطبع رمز الدفعة أسفل العبوة.", "The batch code is printed on the base of the packaging."),
            category: .business,
            related: ["decant"]
        )
    ]

    static func byID(_ id: String) -> GlossaryTerm? {
        all.first { $0.id == id }
    }
}
