import type { LText } from '@/lib/strings';

export type GlossaryCategory = 'structure' | 'materials' | 'technique' | 'families' | 'business';

export const glossaryCategoryLabel: Record<GlossaryCategory, LText> = {
  structure: { ar: 'البنية', en: 'Structure' },
  materials: { ar: 'المواد', en: 'Materials' },
  technique: { ar: 'التقنية', en: 'Technique' },
  families: { ar: 'العائلات', en: 'Families' },
  business: { ar: 'السوق', en: 'Business' },
};

export interface GlossaryTerm {
  id: string;
  termAr: string;
  termEn: string;
  definition: LText;
  example: LText;
  category: GlossaryCategory;
  related: string[];
}

// Ported 1:1 from ios-miyar/MIYAR/Data/SeedGlossary.swift.
export const glossaryTerms: GlossaryTerm[] = [
  { id: 'accord', termAr: 'أكورد', termEn: 'Accord', category: 'structure', related: ['pyramid', 'base'],
    definition: { ar: 'مزيج من مادتين أو أكثر يُنتج رائحة جديدة موحّدة لا تُنسب لأي مادة بمفردها.', en: 'A blend of two or more materials producing a single new smell that belongs to none of them alone.' },
    example: { ar: 'أكورد الشيبر: برغموت + لادن + طحلب البلوط.', en: 'The chypre accord: bergamot + labdanum + oakmoss.' } },
  { id: 'pyramid', termAr: 'هرم العطر', termEn: 'Fragrance pyramid', category: 'structure', related: ['top', 'heart', 'base'],
    definition: { ar: 'تمثيل للعطر في ثلاث طبقات: المقدمة والقلب والقاعدة، مرتبة حسب سرعة التطاير.', en: 'A representation of a perfume in three layers — top, heart and base — ordered by rate of evaporation.' },
    example: { ar: 'مقدمة حمضية، قلب زهري، قاعدة خشبية.', en: 'A citrus top, floral heart and woody base.' } },
  { id: 'top', termAr: 'المقدمة', termEn: 'Top notes', category: 'structure', related: ['pyramid', 'heart'],
    definition: { ar: 'أول ما تشمّه من العطر، مواد سريعة التطاير تختفي عادة خلال ١٥ إلى ٣٠ دقيقة.', en: 'The first impression of a perfume: highly volatile materials that usually vanish within 15 to 30 minutes.' },
    example: { ar: 'البرغموت، الليمون، الهيل.', en: 'Bergamot, lemon, cardamom.' } },
  { id: 'heart', termAr: 'القلب', termEn: 'Heart notes', category: 'structure', related: ['pyramid', 'top', 'base'],
    definition: { ar: 'جوهر العطر الذي يظهر بعد تلاشي المقدمة ويستمر عدة ساعات.', en: 'The core of the perfume, appearing as the top fades and lasting several hours.' },
    example: { ar: 'الياسمين، الورد، النيرولي.', en: 'Jasmine, rose, neroli.' } },
  { id: 'base', termAr: 'القاعدة', termEn: 'Base notes', category: 'structure', related: ['pyramid', 'fixative'],
    definition: { ar: 'المواد الثقيلة بطيئة التطاير التي تمنح العطر ثباته وعمقه.', en: "Heavy, slow-evaporating materials that give the perfume its longevity and depth." },
    example: { ar: 'الصندل، العود، المسك.', en: 'Sandalwood, oud, musk.' } },
  { id: 'sillage', termAr: 'الأثر (سياج)', termEn: 'Sillage', category: 'technique', related: ['projection', 'longevity'],
    definition: { ar: 'الأثر العطري الذي يتركه الشخص خلفه أثناء حركته.', en: 'The scented trail a wearer leaves behind while moving.' },
    example: { ar: 'عطر ذو أثر قوي يُشمّ من مسافة بعيدة.', en: 'A fragrance with strong sillage is noticed from a distance.' } },
  { id: 'projection', termAr: 'الإسقاط', termEn: 'Projection', category: 'technique', related: ['sillage'],
    definition: { ar: 'المسافة التي تنتشر إليها رائحة العطر حول مرتديه في لحظة معينة.', en: 'How far a fragrance radiates around the wearer at a given moment.' },
    example: { ar: 'الأمبروكسان يرفع الإسقاط بوضوح.', en: 'Ambroxan noticeably raises projection.' } },
  { id: 'longevity', termAr: 'الثبات', termEn: 'Longevity', category: 'technique', related: ['fixative', 'base'],
    definition: { ar: 'المدة التي يبقى فيها العطر محسوسًا على الجلد.', en: 'The length of time a fragrance remains perceptible on skin.' },
    example: { ar: 'قاعدة غنية بالمسك تطيل الثبات.', en: 'A musk-rich base extends longevity.' } },
  { id: 'fixative', termAr: 'مثبّت', termEn: 'Fixative', category: 'materials', related: ['base', 'longevity'],
    definition: { ar: 'مادة تبطئ تطاير باقي المكونات فتطيل عمر العطر.', en: "A material that slows the evaporation of the other components, extending the perfume's life." },
    example: { ar: 'اللادن والمسك والصندل من أشهر المثبّتات.', en: 'Labdanum, musk and sandalwood are classic fixatives.' } },
  { id: 'maceration', termAr: 'التعتيق (النقع)', termEn: 'Maceration', category: 'technique', related: ['filtration'],
    definition: { ar: 'ترك التركيبة في مكان مظلم بارد لأسابيع لتندمج مكوناتها وتستقر رائحتها.', en: 'Resting a finished blend in a cool dark place for weeks so the components marry and settle.' },
    example: { ar: 'من أسبوعين إلى ستة أسابيع حسب التركيبة.', en: 'Two to six weeks, depending on the formula.' } },
  { id: 'filtration', termAr: 'الترشيح', termEn: 'Filtration', category: 'technique', related: ['maceration'],
    definition: { ar: 'تصفية العطر بعد التعتيق لإزالة العوالق والحصول على سائل صافٍ.', en: 'Filtering the perfume after maceration to remove particles and obtain a clear liquid.' },
    example: { ar: 'يُستخدم ورق ترشيح دقيق أو مرشّح مخبري.', en: 'A fine filter paper or laboratory filter is used.' } },
  { id: 'blotter', termAr: 'شريط الاختبار', termEn: 'Blotter / mouillette', category: 'technique', related: ['maceration'],
    definition: { ar: 'شريط ورقي ماص يُغمس في العطر لتقييم رائحته عبر الزمن.', en: 'An absorbent paper strip dipped into a fragrance to evaluate it over time.' },
    example: { ar: 'اكتب اسم المادة وتاريخ الغمس على الشريط.', en: 'Write the material name and dipping date on the strip.' } },
  { id: 'absolute', termAr: 'أبسولوت', termEn: 'Absolute', category: 'materials', related: ['essentialoil', 'tincture'],
    definition: { ar: 'مستخلص عطري مركّز يُنتج بالمذيبات، أغنى وأقرب للنبتة الطبيعية من الزيت المقطّر.', en: 'A highly concentrated extract obtained with solvents, richer and closer to the living plant than a distilled oil.' },
    example: { ar: 'أبسولوت الياسمين، أبسولوت الورد.', en: 'Jasmine absolute, rose absolute.' } },
  { id: 'essentialoil', termAr: 'زيت عطري', termEn: 'Essential oil', category: 'materials', related: ['absolute'],
    definition: { ar: 'زيت متطاير يُستخلص بالتقطير البخاري أو العصر البارد.', en: 'A volatile oil obtained by steam distillation or cold pressing.' },
    example: { ar: 'زيت البرغموت يُستخرج بالعصر البارد للقشور.', en: 'Bergamot oil is cold-pressed from the peel.' } },
  { id: 'tincture', termAr: 'صبغة (تنكشر)', termEn: 'Tincture', category: 'materials', related: ['absolute', 'maceration'],
    definition: { ar: 'نقع مادة خام في الكحول لفترة طويلة لاستخلاص رائحتها.', en: 'A raw material steeped in alcohol over a long period to extract its scent.' },
    example: { ar: 'صبغة الفانيليا أو صبغة العود.', en: 'Vanilla tincture or oud tincture.' } },
  { id: 'aldehyde', termAr: 'ألدهيد', termEn: 'Aldehyde', category: 'materials', related: ['accord'],
    definition: { ar: 'مركبات قوية تمنح العطر لمعانًا صابونيًا ومساحة واسعة، تُستخدم بنسب دقيقة جدًا.', en: 'Powerful compounds giving a soapy sparkle and airiness, used in very small amounts.' },
    example: { ar: 'الألدهيدات هي توقيع عطور الخمسينيات الكلاسيكية.', en: 'Aldehydes are the signature of classic 1950s perfumes.' } },
  { id: 'chypre', termAr: 'شيبر', termEn: 'Chypre', category: 'families', related: ['fougere', 'accord'],
    definition: { ar: 'عائلة مبنية على تباين المقدمة الحمضية مع قاعدة من اللادن وطحلب البلوط.', en: 'A family built on the contrast of a citrus top against a labdanum and oakmoss base.' },
    example: { ar: 'برغموت + لادن + طحلب بلوط + باتشولي.', en: 'Bergamot + labdanum + oakmoss + patchouli.' } },
  { id: 'fougere', termAr: 'فوجير', termEn: 'Fougère', category: 'families', related: ['chypre'],
    definition: { ar: 'عائلة تجمع الخزامى والكومارين وطحلب البلوط، وتعني «السرخس» بالفرنسية.', en: "A family combining lavender, coumarin and oakmoss; the name is French for 'fern'." },
    example: { ar: 'خزامى + كومارين + طحلب بلوط.', en: 'Lavender + coumarin + oakmoss.' } },
  { id: 'gourmand', termAr: 'حلويّة (غورماند)', termEn: 'Gourmand', category: 'families', related: ['accord'],
    definition: { ar: 'عائلة تستحضر روائح الطعام الحلو كالفانيليا والكراميل والكاكاو.', en: 'A family evoking sweet edible smells such as vanilla, caramel and cocoa.' },
    example: { ar: 'فانيليا + تونكا + كراميل.', en: 'Vanilla + tonka + caramel.' } },
  { id: 'concentration', termAr: 'التركيز', termEn: 'Concentration', category: 'structure', related: ['dilution'],
    definition: { ar: 'نسبة زيت العطر إلى الكحول في القارورة، وهي ما يحدد التسمية من كولونيا إلى باروفان.', en: 'The ratio of perfume oil to alcohol in the bottle, which determines the naming from cologne to parfum.' },
    example: { ar: 'أو دو بارفان تتراوح عادة بين ١٥٪ و٢٠٪.', en: 'Eau de parfum is typically between 15% and 20%.' } },
  { id: 'dilution', termAr: 'التخفيف', termEn: 'Dilution', category: 'technique', related: ['concentration', 'blotter'],
    definition: { ar: 'خفض تركيز مادة خام بالكحول لتسهيل تقييمها والتحكم في نسبتها.', en: "Reducing a raw material's strength with alcohol to evaluate it and control its dose." },
    example: { ar: 'تُقيَّم أغلب المواد عند تخفيف ١٠٪.', en: 'Most materials are evaluated at a 10% dilution.' } },
  { id: 'ifraterm', termAr: 'معايير IFRA', termEn: 'IFRA standards', category: 'business', related: ['allergen'],
    definition: { ar: 'معايير الرابطة الدولية للمواد العطرية التي تحدد حدود استخدام المواد حسب فئة المنتج.', en: 'Standards of the International Fragrance Association defining usage limits for materials by product category.' },
    example: { ar: 'راجع دائمًا أحدث تعديل قبل الإنتاج.', en: 'Always check the latest amendment before production.' } },
  { id: 'allergen', termAr: 'مسبب حساسية', termEn: 'Allergen', category: 'business', related: ['ifraterm'],
    definition: { ar: 'مكوّن يجب الإفصاح عنه على الملصق عند تجاوز نسبة محددة نظاميًا.', en: 'A component that must be declared on the label above a regulated threshold.' },
    example: { ar: 'يُذكر ضمن قائمة المكونات على العبوة.', en: 'It is listed within the ingredient list on the packaging.' } },
  { id: 'decant', termAr: 'ديكانت', termEn: 'Decant', category: 'business', related: ['sampleterm'],
    definition: { ar: 'كمية تُنقل من قارورة أصلية إلى قارورة أصغر للتجربة أو البيع.', en: 'A quantity transferred from an original bottle into a smaller one for testing or resale.' },
    example: { ar: 'ديكانت ١٠ مل من قارورة ١٠٠ مل.', en: 'A 10 ml decant from a 100 ml bottle.' } },
  { id: 'sampleterm', termAr: 'عينة', termEn: 'Sample', category: 'business', related: ['decant'],
    definition: { ar: 'كمية صغيرة جدًا، غالبًا من ١ إلى ٢ مل، مخصصة للتجربة.', en: 'A very small quantity, usually 1 to 2 ml, intended for trial.' },
    example: { ar: 'عينة ٢ مل تكفي لعدة استخدامات.', en: 'A 2 ml sample is enough for several wears.' } },
  { id: 'batch', termAr: 'دفعة الإنتاج', termEn: 'Batch', category: 'business', related: ['decant'],
    definition: { ar: 'رمز يشير إلى دفعة التصنيع ويُستخدم لتحديد سنة الإنتاج.', en: 'A code identifying the manufacturing run, used to determine the production year.' },
    example: { ar: 'يُطبع رمز الدفعة أسفل العبوة.', en: 'The batch code is printed on the base of the packaging.' } },
];

export function glossaryTermByID(id: string): GlossaryTerm | undefined {
  return glossaryTerms.find((t) => t.id === id);
}
