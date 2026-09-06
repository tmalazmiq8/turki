import type { LText } from '@/lib/strings';
import type { Material, NoteStage } from './material';

export type Concentration = 'parfum' | 'edp' | 'edt' | 'edc' | 'custom';

export const concentrationLabel: Record<Concentration, LText> = {
  parfum: { ar: 'باروفان', en: 'Parfum' },
  edp: { ar: 'EDP', en: 'EDP' },
  edt: { ar: 'EDT', en: 'EDT' },
  edc: { ar: 'EDC', en: 'EDC' },
  custom: { ar: 'مخصص', en: 'Custom' },
};

export const concentrationDefaultPercent: Record<Concentration, number> = {
  parfum: 25,
  edp: 18,
  edt: 10,
  edc: 4,
  custom: 15,
};

export type Currency = 'KWD' | 'SAR' | 'AED' | 'QAR' | 'BHD' | 'OMR' | 'USD';

export const currencySymbol: Record<Currency, LText> = {
  KWD: { ar: 'د.ك', en: 'KWD' },
  SAR: { ar: 'ر.س', en: 'SAR' },
  AED: { ar: 'د.إ', en: 'AED' },
  QAR: { ar: 'ر.ق', en: 'QAR' },
  BHD: { ar: 'د.ب', en: 'BHD' },
  OMR: { ar: 'ر.ع', en: 'OMR' },
  USD: { ar: '$', en: '$' },
};

const currencyPerUSD: Record<Currency, number> = {
  KWD: 0.307,
  SAR: 3.75,
  AED: 3.6725,
  QAR: 3.64,
  BHD: 0.376,
  OMR: 0.3845,
  USD: 1.0,
};

export function formatCurrencyFromUSD(usd: number, currency: Currency, language: 'ar' | 'en'): string {
  const amount = usd * currencyPerUSD[currency];
  const digits = currency === 'KWD' || currency === 'BHD' || currency === 'OMR' ? 3 : 2;
  const symbol = language === 'ar' ? currencySymbol[currency].ar : currencySymbol[currency].en;
  return `${amount.toFixed(digits)} ${symbol}`;
}

export interface FormulaIngredient {
  id: string;
  materialID: string;
  nameAr: string;
  nameEn: string;
  stage: NoteStage;
  /** Share of the oil blend, 0-100. */
  percent: number;
  pricePerMLUSD: number;
  density: number;
}

export interface Formula {
  id: string;
  name: string;
  bottleSizeML: number;
  concentration: Concentration;
  /** Oil share of the finished bottle, 0-100. */
  oilPercent: number;
  currency: Currency;
  ingredients: FormulaIngredient[];
  packagingCostUSD: number;
  alcoholPricePerMLUSD: number;
  dropsPerML: number;
  createdAt: number;
}

export function ingredientFromMaterial(material: Material, percent = 0): FormulaIngredient {
  return {
    id: `${material.id}-${Date.now()}`,
    materialID: material.id,
    nameAr: material.nameAr,
    nameEn: material.nameEn,
    stage: material.stage,
    percent,
    pricePerMLUSD: material.pricePerMLUSD,
    density: material.density,
  };
}

export function newFormula(name: string): Formula {
  return {
    id: `formula-${Date.now()}`,
    name,
    bottleSizeML: 50,
    concentration: 'edp',
    oilPercent: concentrationDefaultPercent.edp,
    currency: 'SAR',
    ingredients: [],
    packagingCostUSD: 1.5,
    alcoholPricePerMLUSD: 0.04,
    dropsPerML: 20,
    createdAt: Date.now(),
  };
}

export function totalPercent(formula: Formula): number {
  return formula.ingredients.reduce((sum, i) => sum + i.percent, 0);
}

export function oilVolumeML(formula: Formula): number {
  return (formula.bottleSizeML * formula.oilPercent) / 100;
}

export function alcoholVolumeML(formula: Formula): number {
  return Math.max(0, formula.bottleSizeML - oilVolumeML(formula));
}

export function ingredientVolumeML(formula: Formula, ingredient: FormulaIngredient): number {
  return (oilVolumeML(formula) * ingredient.percent) / 100;
}

export function ingredientCostUSD(formula: Formula, ingredient: FormulaIngredient): number {
  return ingredientVolumeML(formula, ingredient) * ingredient.pricePerMLUSD;
}

export function totalIngredientCostUSD(formula: Formula): number {
  return formula.ingredients.reduce((sum, i) => sum + ingredientCostUSD(formula, i), 0);
}

export function alcoholCostUSD(formula: Formula): number {
  return alcoholVolumeML(formula) * formula.alcoholPricePerMLUSD;
}

export function totalCostUSD(formula: Formula): number {
  return totalIngredientCostUSD(formula) + alcoholCostUSD(formula) + formula.packagingCostUSD;
}
