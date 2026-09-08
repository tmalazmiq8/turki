#!/usr/bin/env node
import { readFileSync } from 'node:fs';
import { parseArgs } from 'node:util';
import { parseCSV } from './csv.js';
import { createInvoice } from './tapClient.js';

function fail(message) {
  console.error(`خطأ: ${message}`);
  process.exit(1);
}

const { values } = parseArgs({
  options: {
    file: { type: 'string' },
    'dry-run': { type: 'boolean', default: false },
    delay: { type: 'string', default: '1500' },
    help: { type: 'boolean', default: false },
  },
});

if (values.help || !values.file) {
  console.log(`الاستخدام:
  node src/sendBulk.js --file customers.csv [--dry-run] [--delay 1500]

يجب أن يحتوي ملف CSV على الأعمدة التالية (راجع customers.example.csv):
  first_name,last_name,email,country_code,phone,amount,currency,description

--delay: مهلة بالمللي ثانية بين كل فاتورة والتالية (لتجنب تجاوز حدود معدل طلبات تاب).`);
  process.exit(values.help ? 0 : 1);
}

let rows;
try {
  rows = parseCSV(readFileSync(values.file, 'utf8'));
} catch (err) {
  fail(`تعذّرت قراءة الملف ${values.file}: ${err.message}`);
}

if (rows.length === 0) fail('لا توجد صفوف بيانات صالحة في الملف.');

const delayMs = Number(values.delay) || 0;
const results = [];

for (let i = 0; i < rows.length; i++) {
  const row = rows[i];
  const amount = Number(row.amount);
  const rowLabel = `[${i + 1}/${rows.length}]`;

  if (!row.first_name || !row.country_code || !row.phone || !Number.isFinite(amount) || amount <= 0) {
    console.error(`${rowLabel} تم تخطي الصف — بيانات ناقصة أو مبلغ غير صالح: ${JSON.stringify(row)}`);
    results.push({ row: i + 1, ok: false, error: 'بيانات ناقصة أو مبلغ غير صالح' });
    continue;
  }

  const customer = {
    first_name: row.first_name,
    last_name: row.last_name || '',
    phone: { country_code: row.country_code, number: row.phone },
  };
  if (row.email) customer.email = row.email;

  const payload = {
    amount,
    currency: row.currency || process.env.TAP_DEFAULT_CURRENCY || 'SAR',
    customer,
    description: row.description || '',
  };

  if (values['dry-run']) {
    console.log(`${rowLabel} DRY RUN — ${row.first_name}: ${JSON.stringify(payload)}`);
    results.push({ row: i + 1, ok: true, dryRun: true });
    continue;
  }

  try {
    const invoice = await createInvoice(payload);
    console.log(`${rowLabel} تم — ${row.first_name} (${invoice.id ?? '?'}) — ${invoice.url ?? ''}`);
    results.push({ row: i + 1, ok: true, id: invoice.id, url: invoice.url });
  } catch (err) {
    console.error(`${rowLabel} فشل — ${row.first_name}: ${err.message}`);
    results.push({ row: i + 1, ok: false, error: err.message });
  }

  if (i < rows.length - 1 && delayMs > 0) {
    await new Promise((resolve) => setTimeout(resolve, delayMs));
  }
}

const okCount = results.filter((r) => r.ok).length;
console.log(
  `\nالنتيجة: ${okCount}/${rows.length} فاتورة${values['dry-run'] ? ' (dry-run — لم يُرسل شيء فعليًا)' : ''}.`
);
if (okCount < rows.length) process.exitCode = 1;
