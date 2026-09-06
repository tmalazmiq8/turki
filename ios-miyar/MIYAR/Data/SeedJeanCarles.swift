import Foundation

/// The Jean Carles training curriculum: seven steps, Arabic first.
nonisolated enum SeedJeanCarles {
    static let steps: [JeanCarlesStep] = [
        JeanCarlesStep(
            id: 1,
            title: LText("التعرّف على المادة المفردة", "Knowing the single material"),
            summary: LText("اشمم كل مادة وحدها حتى تصبح صورتها الشمّية واضحة في ذاكرتك.", "Smell each material alone until its scent image is clear in your memory."),
            instructions: [
                LText("اختر عشر مواد فقط للبداية، ولا تزد عليها حتى تتقنها.", "Choose ten materials only to begin with, and do not add more until you master them."),
                LText("اغمس شريط اختبار واكتب عليه الاسم والتاريخ.", "Dip a blotter and write the name and date on it."),
                LText("اشممه فورًا، ثم بعد ١٥ دقيقة، ثم بعد ساعة، ثم بعد ٢٤ ساعة.", "Smell immediately, then after 15 minutes, one hour and 24 hours."),
                LText("سجّل القوة والطابع والتطاير بكلماتك أنت لا بكلمات غيرك.", "Record strength, character and evaporation in your own words, not someone else's.")
            ]
        ),
        JeanCarlesStep(
            id: 2,
            title: LText("ضبط نسب التخفيف", "Setting the dilution ratios"),
            summary: LText("لا تُقيَّم أي مادة مركّزة؛ اضبط نسبة تخفيف ثابتة تقارن عليها كل شيء.", "No material is judged neat: fix one dilution ratio and compare everything against it."),
            instructions: [
                LText("جهّز محاليل ١٪ للمواد القوية جدًا مثل الإندول والأوكتين.", "Prepare 1% solutions for very powerful materials such as indole and octine."),
                LText("جهّز محاليل ١٠٪ للمواد المتوسطة، وهي النسبة المرجعية في التدريب.", "Prepare 10% solutions for medium materials — the reference ratio of the training."),
                LText("اترك المواد الخفيفة مثل الحمضيات عند ١٠٠٪ إذا لزم الأمر.", "Leave light materials such as citruses at 100% when needed."),
                LText("اكتب نسبة التخفيف على كل قارورة، وسجّلها في كل تجربة داخل التطبيق.", "Write the dilution on every bottle and record it in each experiment in the app.")
            ]
        ),
        JeanCarlesStep(
            id: 3,
            title: LText("المقارنة الثنائية", "Pairwise comparison"),
            summary: LText("قارن مادتين متقاربتين لتكتشف الفروق الدقيقة بينهما.", "Compare two closely related materials to discover their fine differences."),
            instructions: [
                LText("اختر مادتين من العائلة نفسها، مثل البرغموت والليمون.", "Choose two materials from the same family, such as bergamot and lemon."),
                LText("اشممهما بالتناوب دون توقف طويل بينهما.", "Smell them alternately without long pauses."),
                LText("حدّد أيهما أقوى، وأيهما أطول بقاءً، وأيهما أوضح شخصية.", "Decide which is stronger, which lasts longer and which has the clearer character."),
                LText("سجّل الفرق في تجربة محفوظة داخل التطبيق مع تقييمات القوة والطابع والتطاير والانسجام.", "Record the difference as a saved experiment with strength, character, evaporation and harmony ratings.")
            ]
        ),
        JeanCarlesStep(
            id: 4,
            title: LText("سلالم النسب", "Ratio ladders"),
            summary: LText("امزج مادتين بنسب متدرجة لترى كيف تتغير الشخصية.", "Blend two materials in graded ratios to see how the character shifts."),
            instructions: [
                LText("جهّز خمس عينات بنسب ٩:١ و٧:٣ و٥:٥ و٣:٧ و١:٩.", "Prepare five samples at 9:1, 7:3, 5:5, 3:7 and 1:9."),
                LText("قيّم الانسجام في كل نسبة من ١ إلى ٥.", "Rate the harmony of each ratio from 1 to 5."),
                LText("احتفظ بالنسبة الأفضل كنواة لأكورد مستقبلي.", "Keep the best ratio as the seed of a future accord.")
            ]
        ),
        JeanCarlesStep(
            id: 5,
            title: LText("بناء الأكورد الثلاثي", "Building the three-part accord"),
            summary: LText("أضف مادة ثالثة إلى أفضل ثنائي لديك وراقب الأثر.", "Add a third material to your best pair and watch the effect."),
            instructions: [
                LText("ابدأ بالنسبة الفائزة من الخطوة السابقة.", "Start from the winning ratio of the previous step."),
                LText("أضف المادة الثالثة بنسبة ١٠٪ ثم ٢٠٪ ثم ٣٠٪.", "Add the third material at 10%, then 20%, then 30%."),
                LText("لاحظ متى تختفي إحدى المواد تمامًا.", "Notice the point at which one material disappears entirely."),
                LText("دوّن الحد الذي يفقد فيه الأكورد توازنه.", "Note the threshold where the accord loses its balance.")
            ]
        ),
        JeanCarlesStep(
            id: 6,
            title: LText("الهرم الكامل", "The complete pyramid"),
            summary: LText("اجمع المقدمة والقلب والقاعدة في تركيبة متكاملة.", "Assemble top, heart and base into a complete formula."),
            instructions: [
                LText("ابنِ القاعدة أولًا لأنها تحدد شخصية العطر.", "Build the base first — it defines the perfume's character."),
                LText("أضف القلب حتى يذوب في القاعدة دون انفصال.", "Add the heart until it melts into the base without separating."),
                LText("اختم بالمقدمة بنسبة تتراوح بين ١٥٪ و٣٠٪.", "Finish with a top of between 15% and 30%."),
                LText("انقل التركيبة إلى الحاسبة واحسب المقادير والتكلفة.", "Move the formula to the calculator and compute quantities and cost.")
            ]
        ),
        JeanCarlesStep(
            id: 7,
            title: LText("المراجعة والتدوين", "Review and record keeping"),
            summary: LText("قيّم التركيبة على مدى أيام، ودوّن ما تعلّمته قبل الانتقال إلى الأكورد التالي.", "Evaluate the formula over several days and write down what you learned before moving to the next accord."),
            instructions: [
                LText("اشمم التركيبة بعد ٢٤ ساعة و٤٨ ساعة وبعد أسبوع.", "Smell the formula after 24 hours, 48 hours and one week."),
                LText("اكتب ما تغيّر: هل ضعفت المقدمة؟ هل طغت القاعدة؟", "Write down what changed: did the top fade, did the base take over?"),
                LText("راجع قسم سلامة IFRA لكل مادة قبل أي استخدام على البشرة.", "Review the IFRA safety section for every material before any use on skin."),
                LText("احفظ التجربة النهائية، وابدأ الدورة من جديد بمواد جديدة.", "Save the final experiment and start the cycle again with new materials.")
            ]
        )
    ]

    static func step(_ id: Int) -> JeanCarlesStep? {
        steps.first { $0.id == id }
    }
}
