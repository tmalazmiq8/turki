// Bilingual strings — port of the Swift app's Strings.swift (S enum / LText).
// Every entry is { ar, en }; call `t(strings.xyz, language)` to resolve.
export type Language = 'ar' | 'en';

export interface LText {
  ar: string;
  en: string;
}

export function t(text: LText, language: Language): string {
  return language === 'ar' ? text.ar : text.en;
}

export const S = {
  appName: { ar: 'معيار', en: 'MIYAR' },
  appTagline: { ar: 'عالم العطور بين يديك', en: 'The world of perfumery in your hands' },

  tabHome: { ar: 'الرئيسية', en: 'Home' },
  tabCalculator: { ar: 'الحاسبة', en: 'Calculator' },
  tabMarket: { ar: 'السوق', en: 'Market' },
  tabCommunity: { ar: 'المجتمع', en: 'Community' },
  tabAccount: { ar: 'حسابي', en: 'Account' },

  save: { ar: 'حفظ', en: 'Save' },
  cancel: { ar: 'إلغاء', en: 'Cancel' },
  close: { ar: 'إغلاق', en: 'Close' },
  search: { ar: 'بحث', en: 'Search' },
  retry: { ar: 'إعادة المحاولة', en: 'Retry' },
  loading: { ar: 'جارٍ التحميل…', en: 'Loading…' },
  noResults: { ar: 'لا توجد نتائج', en: 'No results' },
  noResultsHint: { ar: 'جرّب كلمة بحث أخرى.', en: 'Try a different search term.' },

  // Auth
  signIn: { ar: 'تسجيل الدخول', en: 'Sign in' },
  signOut: { ar: 'تسجيل الخروج', en: 'Sign out' },
  createAccount: { ar: 'إنشاء حساب جديد', en: 'Create account' },
  email: { ar: 'البريد الإلكتروني', en: 'Email' },
  password: { ar: 'كلمة المرور', en: 'Password' },
  confirmPassword: { ar: 'تأكيد كلمة المرور', en: 'Confirm password' },
  fullName: { ar: 'الاسم', en: 'Name' },
  forgotPassword: { ar: 'نسيت كلمة المرور؟', en: 'Forgot password?' },
  resetPassword: { ar: 'إعادة تعيين كلمة المرور', en: 'Reset password' },
  resetPasswordHint: {
    ar: 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.',
    en: "Enter your email and we'll send you a reset link.",
  },
  resetLinkSent: {
    ar: 'تم إرسال رابط إعادة التعيين إلى بريدك.',
    en: 'A reset link has been sent to your email.',
  },
  alreadyHaveAccount: { ar: 'لديك حساب؟ تسجيل الدخول', en: 'Have an account? Sign in' },
  backToSignIn: { ar: 'العودة لتسجيل الدخول', en: 'Back to sign in' },
  welcomeTitle: { ar: 'أهلًا بك في معيار', en: 'Welcome to MIYAR' },
  welcomeSubtitle: {
    ar: 'صمّم عطورك، تعلّم المواد، وتحقّق من سلامتها وفق معايير IFRA.',
    en: 'Design your fragrances, learn the materials, and check their IFRA safety.',
  },
  encryptedNotice: { ar: 'معلوماتك محمية بالتشفير', en: 'Your information is protected with encryption' },
  emailVerification: { ar: 'توثيق البريد الإلكتروني', en: 'Email verification' },
  emailVerificationSent: {
    ar: 'أرسلنا رمز توثيق إلى بريدك. أدخله لتفعيل حسابك.',
    en: 'We sent a verification code to your email. Enter it to activate your account.',
  },
  verificationCode: { ar: 'رمز التوثيق', en: 'Verification code' },
  verify: { ar: 'توثيق', en: 'Verify' },
  resendCode: { ar: 'إعادة إرسال الرمز', en: 'Resend code' },

  errInvalidEmail: { ar: 'صيغة البريد الإلكتروني غير صحيحة.', en: "That email address doesn't look right." },
  errShortPassword: { ar: 'كلمة المرور يجب ألا تقل عن ٨ أحرف.', en: 'Password must be at least 8 characters.' },
  errPasswordMismatch: { ar: 'كلمتا المرور غير متطابقتين.', en: 'Passwords do not match.' },
  errEmptyName: { ar: 'الرجاء إدخال الاسم.', en: 'Please enter your name.' },
  errWrongCredentials: { ar: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.', en: 'Incorrect email or password.' },
  errEmailTaken: { ar: 'هذا البريد مسجّل مسبقًا.', en: 'This email is already registered.' },
  errNetwork: { ar: 'تعذّر الاتصال بالخادم. تحقق من الإنترنت.', en: "Couldn't reach the server. Check your connection." },

  // Home
  goodMorning: { ar: 'صباح الخير', en: 'Good morning' },
  goodAfternoon: { ar: 'مساء الخير', en: 'Good afternoon' },
  goodEvening: { ar: 'مساء الخير', en: 'Good evening' },
  quickActions: { ar: 'إجراءات سريعة', en: 'Quick actions' },

  // Materials library
  materialsLibrary: { ar: 'مكتبة المواد', en: 'Materials library' },
  origin: { ar: 'المصدر', en: 'Origin' },
  character: { ar: 'الطابع', en: 'Character' },
  evaporation: { ar: 'التبخّر', en: 'Evaporation' },
  typicalUse: { ar: 'الاستخدام المعتاد', en: 'Typical use' },
  intensity: { ar: 'الشدّة', en: 'Intensity' },
  pricePerMl: { ar: 'السعر لكل مل', en: 'Price per ml' },

  // IFRA
  ifra: { ar: 'سلامة IFRA', en: 'IFRA safety' },
  ifraSection: { ar: 'معلومات سلامة IFRA', en: 'IFRA safety information' },
  ifraDisclaimer: {
    ar: 'هذه المعلومات لأغراض تعليمية فقط ولا تُغني عن مراجعة المعيار الرسمي وشهادة المورّد قبل الإنتاج أو البيع.',
    en: "This information is educational only — always check the official standard and your supplier's certificate before production or sale.",
  },
  ifraNoAutoCompliance: {
    ar: 'لا يقوم التطبيق تلقائيًا بالتحقق من امتثال أي تركيبة لمعايير IFRA.',
    en: 'The app does not automatically verify any formula against IFRA standards.',
  },
  ifraOfficialSearch: {
    ar: 'ابحث عن المواد في موقع IFRA الرسمي',
    en: 'Search materials on the official IFRA website',
  },
  ifraMaterialsWithLimits: { ar: 'مواد ذات قيود', en: 'Materials with restrictions' },
  ifraMax: { ar: 'أقصى تركيز مسموح', en: 'Maximum permitted concentration' },
  ifraUnverified: { ar: 'الحد الرسمي غير مُتحقق منه', en: 'Official limit not verified' },
  ifraSource: { ar: 'المصدر', en: 'Source' },
  ifraAmendment: { ar: 'الإصدار / التعديل', en: 'Amendment / version' },
  ifraCategory: { ar: 'فئة المنتج', en: 'Product category' },
  ifraStatus: { ar: 'الحالة', en: 'Status' },
  ifraRestricted: { ar: 'مقيّدة', en: 'Restricted' },
  ifraProhibited: { ar: 'محظورة', en: 'Prohibited' },
  ifraSpecified: { ar: 'مواصفات خاصة', en: 'Specification' },
  ifraNotListed: { ar: 'غير مدرجة', en: 'Not listed' },
  ifraStatusUnverified: { ar: 'غير مُتحقق منها', en: 'Unverified' },

  // Book
  book: { ar: 'مصمم العطور', en: 'The Perfume Designer' },
  bookSubtitle: { ar: 'كتاب تعليمي في صناعة العطور', en: 'An educational book on perfume-making' },
  minutesRead: { ar: 'دقائق قراءة', en: 'min read' },

  // Calculator
  calculator: { ar: 'حاسبة العطور', en: 'Perfume calculator' },
  newFormula: { ar: 'تركيبة جديدة', en: 'New formula' },
  formulaName: { ar: 'اسم التركيبة', en: 'Formula name' },
  bottleSize: { ar: 'حجم القارورة', en: 'Bottle size' },
  milliliters: { ar: 'مل', en: 'ml' },
  concentration: { ar: 'التركيز', en: 'Concentration' },
  addMaterial: { ar: 'إضافة مادة', en: 'Add material' },
  totalPercentage: { ar: 'مجموع النسب', en: 'Total percentage' },
  totalCost: { ar: 'التكلفة الإجمالية', en: 'Total cost' },
  noFormulas: { ar: 'لا توجد تركيبات بعد', en: 'No formulas yet' },
  noFormulasHint: { ar: 'ابدأ تركيبتك الأولى', en: 'Start your first formula' },
  delete: { ar: 'حذف', en: 'Delete' },

  // Market
  market: { ar: 'السوق', en: 'Market' },
  newListing: { ar: 'إعلان جديد', en: 'New listing' },
  listingTitle: { ar: 'العنوان', en: 'Title' },
  description: { ar: 'الوصف', en: 'Description' },
  price: { ar: 'السعر', en: 'Price' },
  category: { ar: 'الفئة', en: 'Category' },
  post: { ar: 'نشر', en: 'Post' },
  noListings: { ar: 'لا توجد إعلانات بعد', en: 'No listings yet' },
  activeListings: { ar: 'إعلانات نشطة', en: 'Active listings' },
  sellers: { ar: 'بائع', en: 'Sellers' },
  avgPrice: { ar: 'متوسط السعر', en: 'Avg. price' },

  // Community
  community: { ar: 'المجتمع', en: 'Community' },
  newPost: { ar: 'منشور جديد', en: 'New post' },
  writeSomething: { ar: 'اكتب شيئًا...', en: 'Write something...' },
  noPosts: { ar: 'لا توجد منشورات بعد', en: 'No posts yet' },
  members: { ar: 'عضو', en: 'Members' },
  posts: { ar: 'منشور', en: 'Posts' },
  totalLikes: { ar: 'إعجاب', en: 'Likes' },

  // Account / settings
  account: { ar: 'حسابي', en: 'Account' },
  language: { ar: 'اللغة', en: 'Language' },
  officialWebsites: { ar: 'مواقع رسمية', en: 'Official websites' },
  aboutApp: { ar: 'عن التطبيق', en: 'About the app' },
} satisfies Record<string, LText>;
