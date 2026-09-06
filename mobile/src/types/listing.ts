import type { LText } from '@/lib/strings';

export type ListingCategory = 'fullBottle' | 'used' | 'sample' | 'decant' | 'oil' | 'rawMaterial';

export const listingCategoryLabel: Record<ListingCategory, LText> = {
  fullBottle: { ar: 'قارورة كاملة', en: 'Full bottle' },
  used: { ar: 'مستعملة', en: 'Used' },
  sample: { ar: 'عينة', en: 'Sample' },
  decant: { ar: 'تفريغ (ديكانت)', en: 'Decant' },
  oil: { ar: 'زيت عطر', en: 'Perfume oil' },
  rawMaterial: { ar: 'مادة خام', en: 'Raw material' },
};

export interface Listing {
  id: string;
  title: string;
  description: string;
  category: ListingCategory;
  priceUSD: number;
  sellerEmail: string;
  createdAt: number;
}
