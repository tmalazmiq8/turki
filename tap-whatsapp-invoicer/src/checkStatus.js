#!/usr/bin/env node
import { parseArgs } from 'node:util';
import { getInvoice } from './tapClient.js';

const { positionals, values } = parseArgs({
  allowPositionals: true,
  options: { help: { type: 'boolean', default: false } },
});

const invoiceId = positionals[0];

if (values.help || !invoiceId) {
  console.log(`الاستخدام:
  node src/checkStatus.js <invoice_id>

يعرض حالة فاتورة موجودة مسبقًا (مثال: هل تم الدفع، الحالة، رابط الفاتورة).`);
  process.exit(values.help ? 0 : 1);
}

try {
  const invoice = await getInvoice(invoiceId);
  console.log(JSON.stringify(invoice, null, 2));
} catch (err) {
  console.error(`خطأ: ${err.message}`);
  process.exit(1);
}
