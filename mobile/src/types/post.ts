import type { LText } from '@/lib/strings';

export type PostKind = 'question' | 'discussion' | 'photo' | 'educational' | 'formula';

export const postKindLabel: Record<PostKind, LText> = {
  question: { ar: 'سؤال', en: 'Question' },
  discussion: { ar: 'نقاش', en: 'Discussion' },
  photo: { ar: 'صورة', en: 'Photo' },
  educational: { ar: 'تعليمي', en: 'Educational' },
  formula: { ar: 'تركيبة', en: 'Formula' },
};

export interface Post {
  id: string;
  authorEmail: string;
  kind: PostKind;
  body: string;
  createdAt: number;
  likeCount: number;
  isLiked: boolean;
}
