-- MIYAR — Supabase schema
-- Run this once in your project's SQL Editor (Supabase Dashboard → SQL Editor → New query → Run).
-- Safe to re-run: every statement is guarded with IF NOT EXISTS / OR REPLACE.

-- 1) Profiles — one row per signed-up user, linked to Supabase's built-in auth.users.
create table if not exists public.profiles (
    id uuid primary key references auth.users (id) on delete cascade,
    name_ar text not null default '',
    name_en text not null default '',
    bio_ar text not null default '',
    bio_en text not null default '',
    location_ar text not null default '',
    location_en text not null default '',
    phone text not null default '',
    avatar_seed int not null default 0,
    photo_url text,
    show_profile_publicly boolean not null default true,
    allow_direct_messages boolean not null default true,
    is_verified boolean not null default false,
    rating double precision not null default 0,
    sales_count int not null default 0,
    follower_count int not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 2) Formulas — each user's fragrance formulas. Kept as jsonb so the existing
-- Swift `Formula` model can be sent/received as-is without a column per field.
create table if not exists public.formulas (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    data jsonb not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 3) Marketplace listings — shared and publicly browsable.
create table if not exists public.listings (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    data jsonb not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 4) Community posts — shared and publicly browsable.
create table if not exists public.posts (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    data jsonb not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 5) IFRA reference records — published by an admin, read-only for the app.
-- There is intentionally no app-facing insert/update policy: edit these from
-- the Supabase dashboard (Table Editor) or a service-role admin tool, never
-- from the client.
create table if not exists public.ifra_records (
    id text primary key,
    data jsonb not null,
    updated_at timestamptz not null default now()
);

-- Row Level Security: every table starts locked down, then we open exactly
-- what the app needs.
alter table public.profiles enable row level security;
alter table public.formulas enable row level security;
alter table public.listings enable row level security;
alter table public.posts enable row level security;
alter table public.ifra_records enable row level security;

-- Profiles: anyone can read profiles marked public, or their own; only the
-- owner can write their own row.
drop policy if exists "profiles are readable" on public.profiles;
create policy "profiles are readable" on public.profiles
    for select using (show_profile_publicly = true or auth.uid() = id);

drop policy if exists "profiles are insertable by owner" on public.profiles;
create policy "profiles are insertable by owner" on public.profiles
    for insert with check (auth.uid() = id);

drop policy if exists "profiles are updatable by owner" on public.profiles;
create policy "profiles are updatable by owner" on public.profiles
    for update using (auth.uid() = id) with check (auth.uid() = id);

-- The client upserts the whole profile row (see SupabaseProfileService.swift),
-- so RLS alone can't stop an owner from setting their own is_verified/rating/
-- sales_count/follower_count to whatever they like — those are trust/reputation
-- signals that must only ever move as a side effect of real activity (admin
-- verification, a completed sale, a new follower), never a direct client write.
-- This trigger forces safe values on insert and pins the existing value back
-- on update, for any caller that isn't the service role.
create or replace function public.protect_profile_trust_fields()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if auth.role() = 'service_role' then
        return new;
    end if;
    if tg_op = 'INSERT' then
        new.is_verified := false;
        new.rating := 0;
        new.sales_count := 0;
        new.follower_count := 0;
    else
        new.is_verified := old.is_verified;
        new.rating := old.rating;
        new.sales_count := old.sales_count;
        new.follower_count := old.follower_count;
    end if;
    return new;
end;
$$;

drop trigger if exists protect_profile_trust_fields on public.profiles;
create trigger protect_profile_trust_fields
    before insert or update on public.profiles
    for each row execute function public.protect_profile_trust_fields();

-- Formulas: strictly private to the owner.
drop policy if exists "formulas are owner only" on public.formulas;
create policy "formulas are owner only" on public.formulas
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Listings: readable by everyone (it's a marketplace), writable by the owner.
drop policy if exists "listings are publicly readable" on public.listings;
create policy "listings are publicly readable" on public.listings
    for select using (true);

drop policy if exists "listings are writable by owner" on public.listings;
create policy "listings are writable by owner" on public.listings
    for insert with check (auth.uid() = user_id);

drop policy if exists "listings are editable by owner" on public.listings;
create policy "listings are editable by owner" on public.listings
    for update using (auth.uid() = user_id);

drop policy if exists "listings are deletable by owner" on public.listings;
create policy "listings are deletable by owner" on public.listings
    for delete using (auth.uid() = user_id);

-- Posts: same shape as listings — public read, owner write.
drop policy if exists "posts are publicly readable" on public.posts;
create policy "posts are publicly readable" on public.posts
    for select using (true);

drop policy if exists "posts are writable by owner" on public.posts;
create policy "posts are writable by owner" on public.posts
    for insert with check (auth.uid() = user_id);

drop policy if exists "posts are editable by owner" on public.posts;
create policy "posts are editable by owner" on public.posts
    for update using (auth.uid() = user_id);

drop policy if exists "posts are deletable by owner" on public.posts;
create policy "posts are deletable by owner" on public.posts
    for delete using (auth.uid() = user_id);

-- IFRA records: readable by any signed-in or anonymous client, no client writes.
drop policy if exists "ifra records are publicly readable" on public.ifra_records;
create policy "ifra records are publicly readable" on public.ifra_records
    for select using (true);
