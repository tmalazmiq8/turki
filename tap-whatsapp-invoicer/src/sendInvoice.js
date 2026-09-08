#!/usr/bin/env node
import { parseArgs } from 'node:util';
import { createInvoice } from './tapClient.js';

function fail(message) {
  console.error(`خطأ: ${message}`);
  process.exit(1);
}

function usage() {
  console.log(`الاستخدام:
  node src/sendInvoice.js --first-name "اسم" --country-code 966 --phone 501234567 --amount 250 [خيارات]

الخيارات:
  --first-name       اسم العميل الأول (مطلوب)
  --last-name        اسم العميل الأخير (اختياري)
  --email            بريد العميل الإلكتروني (اختياري)
  --country-code     رمز الدولة بدون + (مثال: 966) (مطلوب)
  --phone            رقم الجوال بدون رمز الدولة (مثال: 501234567) (مطلوب)
  --amount           مبلغ الفاتورة (مطلوب، رقم أكبر من صفر)
  --currency         العملة (افتراضيًا SAR أو TAP_DEFAULT_CURRENCY)
  --description      وصف/بيان الفاتورة (اختياري)
  --dry-run          عرض الطلب فقط بدون إرساله فعليًا لتاب
  --help             عرض هذه الرسالة`);
}

const { values } = parseArgs({
  options: {
    'first-name': { type: 'string' },
    'last-name': { type: 'string', default: '' },
    email: { type: 'string' },
    'country-code': { type: 'string' },
    phone: { type: 'string' },
    amount: { type: 'string' },
    currency: { type: 'string', default: process.env.TAP_DEFAULT_CURRENCY || 'SAR' },
    description: { type: 'string', default: '' },
    'dry-run': { type: 'boolean', default: false },
    help: { type: 'boolean', default: false },
  },
});

if (values.help) {
  usage();
  process.exit(0);
}

if (!values['first-name']) fail('--first-name مطلوب');
if (!values['country-code'] || !values.phone) {
  fail('--country-code و --phone مطلوبان (مثال: --country-code 966 --phone 501234567)');
}
if (!values.amount) fail('--amount مطلوب');

const amount = Number(values.amount);
if (!Number.isFinite(amount) || amount <= 0) fail('--amount يجب أن يكون رقمًا أكبر من صفر');

const customer = {
  first_name: values['first-name'],
  last_name: values['last-name'],
  phone: { country_code: values['country-code'], number: values.phone },
};
if (values.email) customer.email = values.email;

const payload = {
  amount,
  currency: values.currency,
  customer,
  description: values.description,
};

if (values['dry-run']) {
  console.log('DRY RUN — لن يتم إرسال أي طلب فعلي إلى تاب. الطلب الذي كان سيُرسل:');
  console.log(JSON.stringify(payload, null, 2));
  process.exit(0);
}

try {
  const invoice = await createInvoice(payload);
  console.log('تم إنشاء الفاتورة بنجاح.');
  console.log(`  المعرّف: ${invoice.id ?? '(غير متوفر في الرد)'}`);
  console.log(`  الحالة: ${invoice.status ?? '?'}`);
  console.log(`  رابط الفاتورة: ${invoice.url ?? '(غير متوفر في الرد)'}`);
  console.log('\nالرد الكامل من تاب (تحقق منه لمعرفة إن وصل إشعار واتساب فعليًا):');
  console.log(JSON.stringify(invoice, null, 2));
} catch (err) {
  fail(err.message);
}
