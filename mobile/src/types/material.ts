import type { LText } from '@/lib/strings';

export type OlfactoryFamily =
  | 'citrus'
  | 'floral'
  | 'woody'
  | 'oriental'
  | 'aromatic'
  | 'chypre'
  | 'fougere'
  | 'gourmand'
  | 'musk'
  | 'animalic'
  | 'green'
  | 'aldehydic';

export const familyLabel: Record<OlfactoryFamily, LText> = {
  citrus: { ar: 'حمضية', en: 'Citrus' },
  floral: { ar: 'زهرية', en: 'Floral' },
  woody: { ar: 'خشبية', en: 'Woody' },
  oriental: { ar: 'شرقية', en: 'Oriental' },
  aromatic: { ar: 'عطرية عشبية', en: 'Aromatic' },
  chypre: { ar: 'شيبر', en: 'Chypre' },
  fougere: { ar: 'فوجير', en: 'Fougère' },
  gourmand: { ar: 'حلوة', en: 'Gourmand' },
  musk: { ar: 'مسك', en: 'Musk' },
  animalic: { ar: 'حيوانية', en: 'Animalic' },
  green: { ar: 'خضراء', en: 'Green' },
  aldehydic: { ar: 'ألدهيدية', en: 'Aldehydic' },
};

// Ionicons name per family (visual equivalent of the Swift app's SF Symbols).
export const familyIcon: Record<OlfactoryFamily, string> = {
  citrus: 'sunny-outline',
  floral: 'flower-outline',
  woody: 'leaf-outline',
  oriental: 'flame-outline',
  aromatic: 'leaf-outline',
  chypre: 'water-outline',
  fougere: 'leaf-outline',
  gourmand: 'ice-cream-outline',
  musk: 'cloud-outline',
  animalic: 'paw-outline',
  green: 'leaf-outline',
  aldehydic: 'sparkles-outline',
};

export type NoteStage = 'top' | 'heart' | 'base';

export const stageLabel: Record<NoteStage, LText> = {
  top: { ar: 'المقدمة', en: 'Top notes' },
  heart: { ar: 'القلب', en: 'Heart notes' },
  base: { ar: 'القاعدة', en: 'Base notes' },
};

export interface Material {
  id: string;
  nameAr: string;
  nameEn: string;
  family: OlfactoryFamily;
  stage: NoteStage;
  origin: LText;
  character: LText;
  evaporation: LText;
  typicalUse: LText;
  pairings: string[];
  intensity: 1 | 2 | 3;
  pricePerMLUSD: number;
  density: number;
}

export function materialName(material: Material, language: 'ar' | 'en'): string {
  return language === 'ar' ? material.nameAr : material.nameEn;
}

export type IFRAStatus = 'restricted' | 'prohibited' | 'specification' | 'notListed' | 'unverified';

export const ifraStatusLabel: Record<IFRAStatus, LText> = {
  restricted: { ar: 'مقيّدة', en: 'Restricted' },
  prohibited: { ar: 'محظورة', en: 'Prohibited' },
  specification: { ar: 'مواصفات خاصة', en: 'Specification' },
  notListed: { ar: 'غير مدرجة', en: 'Not listed' },
  unverified: { ar: 'غير مُتحقق منها', en: 'Unverified' },
};

export interface IFRARecord {
  id: string;
  amendment: string;
  productCategory: LText;
  status: IFRAStatus;
  /** `null` means no officially verified figure is available for this record. */
  maxConcentrationPercent: number | null;
  sourceURL: string;
  note?: LText;
}
