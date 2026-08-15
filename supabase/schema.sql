-- Kwentapp schema. Safe to re-run.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null default '',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.posts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  title      text not null,
  body       text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.post_images (
  id           uuid primary key default gen_random_uuid(),
  post_id      uuid not null references public.posts(id) on delete cascade,
  storage_path text not null,
  position     int  not null default 0
);

create table if not exists public.comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.comment_images (
  id           uuid primary key default gen_random_uuid(),
  comment_id   uuid not null references public.comments(id) on delete cascade,
  storage_path text not null,
  position     int  not null default 0
);

create index if not exists posts_created_at_idx
  on public.posts (created_at desc);
create index if not exists posts_user_id_idx
  on public.posts (user_id);
create index if not exists post_images_post_id_position_idx
  on public.post_images (post_id, position);
create index if not exists comments_post_id_created_at_idx
  on public.comments (post_id, created_at);
create index if not exists comments_user_id_idx
  on public.comments (user_id);
create index if not exists comment_images_comment_id_position_idx
  on public.comment_images (comment_id, position);

-- Profile row is created by the database, not the client: the app can read a
-- profile immediately after signup without a second round trip that might fail.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', ''))
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- updated_at is maintained by the database: a client can forget, a trigger cannot.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_updated_at();

drop trigger if exists posts_touch_updated_at on public.posts;
create trigger posts_touch_updated_at
  before update on public.posts
  for each row execute function public.touch_updated_at();

drop trigger if exists comments_touch_updated_at on public.comments;
create trigger comments_touch_updated_at
  before update on public.comments
  for each row execute function public.touch_updated_at();

-- Buckets are created in SQL so bucket creation is versioned with everything
-- else, instead of living only in someone's console click history.
insert into storage.buckets (id, name, public)
values
  ('post-images',    'post-images',    true),
  ('comment-images', 'comment-images', true),
  ('avatars',        'avatars',        true)
on conflict (id) do nothing;
