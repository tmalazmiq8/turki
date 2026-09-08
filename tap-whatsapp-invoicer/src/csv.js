// محلل CSV بسيط يدعم الحقول المقتبسة (") التي قد تحتوي على فواصل أو أسطر جديدة.
export function parseCSV(text) {
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;

  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inQuotes) {
      if (c === '"') {
        if (text[i + 1] === '"') {
          field += '"';
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field += c;
      }
      continue;
    }

    if (c === '"') {
      inQuotes = true;
    } else if (c === ',') {
      row.push(field);
      field = '';
    } else if (c === '\n' || c === '\r') {
      if (c === '\r' && text[i + 1] === '\n') i++;
      row.push(field);
      field = '';
      rows.push(row);
      row = [];
    } else {
      field += c;
    }
  }
  if (field !== '' || row.length) {
    row.push(field);
    rows.push(row);
  }

  const nonEmptyRows = rows.filter((r) => r.some((f) => f.trim() !== ''));
  const [header, ...data] = nonEmptyRows;
  if (!header) return [];

  const cleanHeader = header.map((h) => h.trim());
  return data.map((r) => Object.fromEntries(cleanHeader.map((h, idx) => [h, (r[idx] ?? '').trim()])));
}
