import type { IFRARecord } from '@/types/material';
import { IFRAInfo } from '@/lib/ifra';
import { materials } from './materials';

// Port of ios-miyar/MIYAR/Data/SeedIFRA.swift.
//
// IMPORTANT: no numeric limit is ever invented here. Records ship with
// maxConcentrationPercent === null, which the UI renders as "Official limit
// not verified". Verified figures come only from the server or an admin.
const RESTRICTED_IDS = new Set([
  'oakmoss', 'coumarin', 'cinnamon', 'citral', 'lemon', 'bergamot', 'galbanum', 'ylang', 'rose', 'jasmine',
]);

export function defaultIFRARecords(): Record<string, IFRARecord> {
  const records: Record<string, IFRARecord> = {};
  for (const material of materials) {
    const isRestricted = RESTRICTED_IDS.has(material.id);
    records[material.id] = {
      id: material.id,
      amendment: isRestricted ? 'IFRA Standards — latest amendment' : '—',
      productCategory: isRestricted
        ? { ar: 'يُرجى تحديد الفئة من المعيار الرسمي', en: 'Determine the category from the official standard' }
        : { ar: 'غير محدد', en: 'Not specified' },
      status: isRestricted ? 'restricted' : 'unverified',
      maxConcentrationPercent: null,
      sourceURL: IFRAInfo.officialURL,
      note: isRestricted
        ? {
            ar: 'هذه المادة مشمولة بمعيار IFRA. لم يتم التحقق من الرقم الرسمي داخل التطبيق — راجع أحدث معيار وشهادة المورد.',
            en: "This material is covered by an IFRA standard. The official figure has not been verified in-app — check the latest standard and the supplier's certificate.",
          }
        : undefined,
    };
  }
  return records;
}
