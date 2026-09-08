const TAP_API_BASE = process.env.TAP_API_BASE_URL || 'https://api.tap.company/v2';

function requireSecretKey() {
  const key = process.env.TAP_SECRET_KEY;
  if (!key) {
    throw new Error(
      'متغير البيئة TAP_SECRET_KEY غير موجود. أضفه في ملف .env (انسخ .env.example) ثم شغّل الأمر عبر ' +
        '"node --env-file=.env ..." أو صدّره في الطرفية قبل التشغيل.'
    );
  }
  return key;
}

function defaultNotificationsPayload() {
  // إرسال best-effort يطلب من تاب تسليم الفاتورة عبر واتساب. اسم الحقل الدقيق
  // لم يُتحقق منه من توثيق Tap الرسمي (developers.tap.company كان محجوبًا من
  // بيئة البناء). راجع .env.example لتخصيص القيمة عبر TAP_NOTIFICATIONS_PAYLOAD
  // إذا لم يصل الإشعار فعليًا عبر واتساب.
  return { channels: ['whatsapp'] };
}

function buildNotificationsPayload() {
  const raw = process.env.TAP_NOTIFICATIONS_PAYLOAD;
  if (!raw) return defaultNotificationsPayload();
  try {
    return JSON.parse(raw);
  } catch {
    throw new Error('TAP_NOTIFICATIONS_PAYLOAD في ملف .env ليس JSON صالحًا.');
  }
}

async function tapRequest(path, options = {}) {
  const key = requireSecretKey();
  const res = await fetch(`${TAP_API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${key}`,
      ...(options.headers || {}),
    },
  });

  const text = await res.text();
  let body;
  try {
    body = text ? JSON.parse(text) : {};
  } catch {
    body = { raw: text };
  }

  if (!res.ok) {
    const details = Array.isArray(body.errors)
      ? body.errors.map((e) => `${e.code ?? ''} ${e.description ?? ''}`.trim()).filter(Boolean).join(' | ')
      : JSON.stringify(body);
    throw new Error(`تاب رفض الطلب (HTTP ${res.status}): ${details || 'لا تفاصيل إضافية من تاب'}`);
  }

  return body;
}

export async function createInvoice({ amount, currency, customer, description, mode = 'INVOICE', due }) {
  const payload = {
    amount,
    currency,
    customer,
    mode,
    notifications: buildNotificationsPayload(),
  };
  if (description) payload.description = description;
  if (due) payload.due = due;

  return tapRequest('/invoices', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}

export async function getInvoice(id) {
  return tapRequest(`/invoices/${encodeURIComponent(id)}`, { method: 'GET' });
}
