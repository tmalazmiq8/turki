import { createContext, useContext, useMemo, useState, type ReactNode } from 'react';
import { useAuth } from './auth-context';
import type { Formula } from '@/types/formula';
import type { Listing } from '@/types/listing';
import type { Post } from '@/types/post';

// In-memory app data (formulas, marketplace listings, community posts) — same
// "still local, not yet synced to Supabase" state as the Swift app is
// currently in (see AuthFlowView's backendLocalNotice). Kept in memory only,
// consistent with the auth session (see lib/supabase.ts for why).
interface DataContextValue {
  formulas: Formula[];
  addFormula: (formula: Formula) => void;
  updateFormula: (formula: Formula) => void;
  deleteFormula: (id: string) => void;

  listings: Listing[];
  addListing: (listing: Listing) => void;

  posts: Post[];
  addPost: (post: Post) => void;
  toggleLike: (postId: string) => void;
}

const DataContext = createContext<DataContextValue | null>(null);

const seedListings: Listing[] = [
  {
    id: 'seed-listing-1',
    title: 'ديكانت عود ملكي 5 مل',
    description: 'ديكانت أصلي من قارورة أصلية، تخزين ممتاز.',
    category: 'decant',
    priceUSD: 12,
    sellerEmail: 'majid@example.com',
    createdAt: Date.now() - 86_400_000,
  },
  {
    id: 'seed-listing-2',
    title: 'زيت صندل هندي خام',
    description: '10 مل زيت صندل ميسور نقي، مناسب لتركيبات القاعدة.',
    category: 'rawMaterial',
    priceUSD: 45,
    sellerEmail: 'sara@example.com',
    createdAt: Date.now() - 3 * 86_400_000,
  },
];

const seedPosts: Post[] = [
  {
    id: 'seed-post-1',
    authorEmail: 'nora@example.com',
    kind: 'discussion',
    body: 'وش رأيكم بأفضل نسبة للياسمين في تركيبة زهرية دافئة؟ أحس عندي زيادة بالحدة.',
    createdAt: Date.now() - 3600_000,
    likeCount: 4,
    isLiked: false,
  },
  {
    id: 'seed-post-2',
    authorEmail: 'khaled@example.com',
    kind: 'educational',
    body: 'تجربة Jean Carles الزوجية طريقة رائعة لفهم كيف تتفاعل المواد مع بعض قبل بناء تركيبة كاملة.',
    createdAt: Date.now() - 2 * 3600_000,
    likeCount: 9,
    isLiked: true,
  },
];

export function DataProvider({ children }: { children: ReactNode }) {
  const { session } = useAuth();
  const [formulas, setFormulas] = useState<Formula[]>([]);
  const [listings, setListings] = useState<Listing[]>(seedListings);
  const [posts, setPosts] = useState<Post[]>(seedPosts);

  const value = useMemo<DataContextValue>(
    () => ({
      formulas,
      addFormula: (formula) => setFormulas((prev) => [formula, ...prev]),
      updateFormula: (formula) =>
        setFormulas((prev) => prev.map((f) => (f.id === formula.id ? formula : f))),
      deleteFormula: (id) => setFormulas((prev) => prev.filter((f) => f.id !== id)),

      listings,
      addListing: (listing) => setListings((prev) => [listing, ...prev]),

      posts,
      addPost: (post) => setPosts((prev) => [post, ...prev]),
      toggleLike: (postId) =>
        setPosts((prev) =>
          prev.map((p) =>
            p.id === postId
              ? { ...p, isLiked: !p.isLiked, likeCount: p.likeCount + (p.isLiked ? -1 : 1) }
              : p,
          ),
        ),
    }),
    [formulas, listings, posts],
  );

  // session is read so this provider re-renders (and could reset data) on
  // sign-out if we choose to later; referencing it keeps that door open.
  void session;

  return <DataContext.Provider value={value}>{children}</DataContext.Provider>;
}

export function useAppData(): DataContextValue {
  const ctx = useContext(DataContext);
  if (!ctx) throw new Error('useAppData must be used within DataProvider');
  return ctx;
}
