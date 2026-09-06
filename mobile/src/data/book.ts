import type { LText } from '@/lib/strings';

export interface BookChapter {
  id: number;
  title: LText;
  subtitle: LText;
  paragraphs: LText[];
  isPremium: boolean;
}

// Ported 1:1 from ios-miyar/MIYAR/Data/SeedBook.swift — "مصمم العطور".
export const bookChapters: BookChapter[] = [
  {
    id: 1,
    title: { ar: 'لماذا نصمم العطور؟', en: 'Why we design perfumes' },
    subtitle: { ar: 'مدخل إلى الحرفة', en: 'An introduction to the craft' },
    isPremium: false,
    paragraphs: [
      {
        ar: 'تصميم العطر ليس خلطًا عشوائيًا لزيوت جميلة، بل هو بناء معماري لرائحة تتحرك في الزمن. أنت لا تصنع لحظة واحدة، بل تصنع رحلة تبدأ عند أول رشّة وتنتهي بعد ساعات على الجلد.',
        en: 'Designing a perfume is not the random mixing of pretty oils; it is the architecture of a smell that moves through time. You are not making a single moment, but a journey that starts at the first spray and ends hours later on the skin.',
      },
      {
        ar: 'المصمم الجيد يعرف أن لكل مادة شخصية: بعضها يتكلم بصوت عالٍ ثم يصمت، وبعضها يهمس لكنه يبقى إلى الصباح. مهمتك أن ترتب هذه الأصوات في جوقة متناغمة لا يطغى فيها صوت على آخر.',
        en: 'A good designer knows that every material has a personality: some speak loudly then fall silent, others whisper but stay until morning. Your task is to arrange these voices into a choir where none overwhelms the rest.',
      },
      {
        ar: 'قبل أن تخلط قطرة واحدة، درّب أنفك. الذاكرة الشمّية هي رأس مالك الحقيقي، وهي تُبنى بالتكرار المنظّم لا بالموهبة وحدها.',
        en: 'Before you blend a single drop, train your nose. Scent memory is your real capital, and it is built through organised repetition, not talent alone.',
      },
    ],
  },
  {
    id: 2,
    title: { ar: 'لغة الروائح', en: 'The language of smell' },
    subtitle: { ar: 'العائلات العطرية وكيف نصفها', en: 'Olfactory families and how we describe them' },
    isPremium: false,
    paragraphs: [
      {
        ar: 'لكي تتحدث عن الرائحة، تحتاج مفردات. العائلات العطرية هي هذه المفردات: الحمضية، الزهرية، الخشبية، الشرقية، الشيبر، الفوجير، الحلوية، والمسكية. كل عائلة تحمل توقعًا ذهنيًا لدى من يشمّها.',
        en: 'To speak about smell you need vocabulary. The olfactory families are that vocabulary: citrus, floral, woody, oriental, chypre, fougère, gourmand and musk. Each family carries a mental expectation for whoever smells it.',
      },
      {
        ar: 'لكن العائلة وحدها لا تكفي. صف المادة بثلاث كلمات على الأقل: قوتها، طابعها، وسرعة تطايرها. «برغموت» ليست وصفًا، أما «حمضي مشرق مع مرارة خفيفة يتلاشى خلال ربع ساعة» فهي وصف يمكن العمل به.',
        en: "But the family alone is not enough. Describe a material with at least three words: its strength, its character and its rate of evaporation. 'Bergamot' is not a description; 'bright citrus with slight bitterness, gone within a quarter hour' is one you can work with.",
      },
      {
        ar: 'احتفظ بدفتر. اكتب فيه انطباعك قبل أن تقرأ رأي غيرك، فالانطباع المستعار يفسد التدريب.',
        en: "Keep a notebook. Write your impression before reading anyone else's — a borrowed impression corrupts the training.",
      },
    ],
  },
  {
    id: 3,
    title: { ar: 'الهرم: مقدمة وقلب وقاعدة', en: 'The pyramid: top, heart and base' },
    subtitle: { ar: 'كيف يتحرك العطر في الزمن', en: 'How a perfume moves through time' },
    isPremium: false,
    paragraphs: [
      {
        ar: 'المقدمة هي التحية الأولى: مواد خفيفة سريعة التطاير تعيش من عشر دقائق إلى نصف ساعة. القلب هو جسد العطر وشخصيته، ويستمر من ساعتين إلى ست. القاعدة هي الذاكرة التي تبقى، وقد تمتد ليومين.',
        en: 'The top is the first greeting: light, volatile materials living from ten minutes to half an hour. The heart is the body and personality, lasting two to six hours. The base is the memory that remains, sometimes for two days.',
      },
      {
        ar: 'الخطأ الأكثر شيوعًا عند المبتدئين هو تضخيم المقدمة. رائحة مبهرة في الدقيقة الأولى ثم فراغ بعد نصف ساعة تعني تركيبة غير متوازنة. ابنِ القاعدة أولًا، ثم القلب، ثم أضف المقدمة أخيرًا.',
        en: "The most common beginner's error is inflating the top. A dazzling first minute followed by emptiness after half an hour means an unbalanced formula. Build the base first, then the heart, and add the top last.",
      },
      {
        ar: 'كنسبة إرشادية للبدء: مقدمة بين ١٥٪ و٣٠٪، قلب بين ٣٠٪ و٥٠٪، قاعدة بين ٢٥٪ و٥٠٪ من خلطة الزيت. هذه ليست قاعدة مقدسة لكنها نقطة انطلاق آمنة.',
        en: 'As a starting guide: a top between 15% and 30%, a heart between 30% and 50%, and a base between 25% and 50% of the oil blend. This is not sacred, but it is a safe launching point.',
      },
    ],
  },
  {
    id: 4,
    title: { ar: 'منهج جان كارل', en: 'The Jean Carles method' },
    subtitle: { ar: 'التدريب المنظّم للأنف', en: 'Systematic training for the nose' },
    isPremium: false,
    paragraphs: [
      {
        ar: 'وضع جان كارل، معلّم العطارين في غراس، منهجًا يقوم على مبدأ بسيط: لا تتعلم مئة مادة دفعة واحدة، بل تعلّم مادتين وقارن بينهما حتى تفرّق بينهما وأنت مغمض العينين.',
        en: 'Jean Carles, the teacher of perfumers in Grasse, built a method on a simple principle: do not learn a hundred materials at once — learn two and compare them until you can tell them apart with your eyes closed.',
      },
      {
        ar: 'تبدأ بالمادة المفردة عند تخفيف ١٠٪، ثم تنتقل إلى المقارنة الثنائية، ثم إلى سلالم النسب: ٩:١ و٧:٣ و٥:٥ و٣:٧ و١:٩. في كل نسبة تسأل نفسك: من يقود الآن؟ ومتى اختفى الآخر؟',
        en: 'You start with the single material at a 10% dilution, then move to pairwise comparison, then to ratio ladders: 9:1, 7:3, 5:5, 3:7, 1:9. At each ratio you ask: who leads now, and at what point did the other disappear?',
      },
      {
        ar: 'بعد أن تتقن الثنائيات، أضف مادة ثالثة وراقب كيف تعيد ترتيب العلاقة كلها. هنا تبدأ فعلًا في تصميم الأكوردات بدل تجميع الزيوت.',
        en: 'Once you master pairs, add a third material and watch it rearrange the whole relationship. This is where you truly begin designing accords instead of collecting oils.',
      },
    ],
  },
  {
    id: 5,
    title: { ar: 'الحساب والتكلفة', en: 'Calculation and cost' },
    subtitle: { ar: 'من النسبة إلى القارورة', en: 'From percentage to bottle' },
    isPremium: false,
    paragraphs: [
      {
        ar: 'التركيبة تُكتب دائمًا بالنسب المئوية من خلطة الزيت، ومجموعها يجب أن يساوي ١٠٠٪ بالضبط. بعد ذلك تحدد حجم القارورة والتركيز، فتتحول النسب إلى مليلترات وغرامات وقطرات.',
        en: 'A formula is always written in percentages of the oil blend, and the total must equal exactly 100%. You then set the bottle size and concentration, and the percentages become millilitres, grams and drops.',
      },
      {
        ar: 'مثال: قارورة ٥٠ مل بتركيز ٢٠٪ تعني ١٠ مل زيت و٤٠ مل كحول. مادة تمثل ١٥٪ من الخلطة تعني ١٫٥ مل، أي نحو ٣٠ قطرة عند احتساب ٢٠ قطرة لكل مل.',
        en: 'Example: a 50 ml bottle at 20% means 10 ml of oil and 40 ml of alcohol. A material at 15% of the blend is 1.5 ml — roughly 30 drops at 20 drops per millilitre.',
      },
      {
        ar: 'احسب التكلفة دائمًا قبل أن تعد أحدًا بسعر. تكلفة المواد والكحول والقارورة والتغليف تتغير مع كل دفعة، ومصمم العطور المحترف يعرف رقمه بدقة.',
        en: 'Always compute your cost before promising anyone a price. Materials, alcohol, bottle and packaging change with every batch, and a professional designer knows their number precisely.',
      },
    ],
  },
  {
    id: 6,
    title: { ar: 'السلامة والمسؤولية', en: 'Safety and responsibility' },
    subtitle: { ar: 'قبل أن تضع العطر على جلد أحد', en: "Before you put a perfume on anyone's skin" },
    isPremium: false,
    paragraphs: [
      {
        ar: 'كل مادة عطرية هي مادة كيميائية، سواء كانت طبيعية أو تخليقية. الطبيعي ليس بالضرورة آمنًا، والتخليقي ليس بالضرورة ضارًا. القرار يعود إلى البيانات لا إلى الانطباع.',
        en: 'Every fragrance material is a chemical, whether natural or synthetic. Natural is not automatically safe, and synthetic is not automatically harmful. The decision belongs to the data, not to impressions.',
      },
      {
        ar: 'معايير IFRA تحدد حدود الاستخدام حسب فئة المنتج، وتتغير مع كل تعديل جديد. لا تعتمد على رقم حفظته قبل سنوات، ولا على رقم منشور في منتدى. ارجع إلى المعيار الرسمي وإلى شهادة المورد.',
        en: "IFRA standards set usage limits by product category and change with each new amendment. Do not rely on a figure you memorised years ago, nor on one posted in a forum. Return to the official standard and the supplier's certificate.",
      },
      {
        ar: 'هذا الكتاب وهذا التطبيق أدوات تعليمية. لا يصدر أي منهما شهادة مطابقة، ولا يُغني عن تقييم مختص سلامة قبل الإنتاج التجاري.',
        en: 'This book and this app are educational tools. Neither issues a certificate of compliance, and neither replaces a qualified safety assessment before commercial production.',
      },
    ],
  },
  {
    id: 7,
    title: { ar: 'بناء توقيعك الخاص', en: 'Building your signature' },
    subtitle: { ar: 'من التقليد إلى الصوت الشخصي', en: 'From imitation to a personal voice' },
    isPremium: true,
    paragraphs: [
      {
        ar: 'بعد أن تتقن الأساسيات، يبدأ السؤال الأصعب: ما الذي يجعل عطرك أنت؟ الجواب غالبًا ليس مادة نادرة، بل علاقة غير متوقعة بين مادتين مألوفتين.',
        en: 'Once you master the basics, the harder question begins: what makes a perfume yours? The answer is rarely a rare material — it is usually an unexpected relationship between two familiar ones.',
      },
      {
        ar: 'اختر ثلاث مواد تحبها حقًا واجعلها خيطًا يمر في كل أعمالك. هذا التكرار الواعي هو ما يسميه النقاد «التوقيع».',
        en: 'Choose three materials you genuinely love and let them run like a thread through all your work. That conscious repetition is what critics call a signature.',
      },
    ],
  },
  {
    id: 8,
    title: { ar: 'من التركيبة إلى المنتج', en: 'From formula to product' },
    subtitle: { ar: 'الإنتاج والتسعير والإطلاق', en: 'Production, pricing and launch' },
    isPremium: true,
    paragraphs: [
      {
        ar: 'تحويل تركيبة ناجحة إلى منتج يتطلب قرارات مختلفة تمامًا: حجم الدفعة، مصدر القوارير، الملصق، التوثيق النظامي، والتسعير الذي يغطي التكلفة والمخاطرة معًا.',
        en: 'Turning a successful formula into a product demands entirely different decisions: batch size, bottle sourcing, labelling, regulatory documentation, and pricing that covers both cost and risk.',
      },
      {
        ar: 'ابدأ بدفعة صغيرة. الدفعة الأولى تعلّمك عن التعتيق والترشيح والتعبئة أكثر من أي كتاب.',
        en: 'Start with a small batch. The first batch teaches you more about maceration, filtration and filling than any book.',
      },
    ],
  },
];

export function bookChapterByID(id: number): BookChapter | undefined {
  return bookChapters.find((c) => c.id === id);
}

export function estimatedMinutes(chapter: BookChapter): number {
  const words = chapter.paragraphs.reduce((sum, p) => sum + p.ar.split(' ').length, 0);
  return Math.max(2, Math.round(words / 90));
}
