-- Kwentapp Row Level Security. Safe to re-run.
-- Model: public read everywhere (the feed must work logged out),
-- owner-only writes, ownership immutable, image rows never updated.

alter table public.profiles       enable row level security;
alter table public.posts          enable row level security;
alter table public.post_images    enable row level security;
alter table public.comments       enable row level security;
alter table public.comment_images enable row level security;

-- profiles ------------------------------------------------------------------

drop policy if exists profiles_select_public on public.profiles;
create policy profiles_select_public
  on public.profiles for select
  using (true);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- posts ---------------------------------------------------------------------

drop policy if exists posts_select_public on public.posts;
create policy posts_select_public
  on public.posts for select
  using (true);

drop policy if exists posts_insert_own on public.posts;
create policy posts_insert_own
  on public.posts for insert
  with check (auth.uid() = user_id);

drop policy if exists posts_update_own on public.posts;
create policy posts_update_own
  on public.posts for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists posts_delete_own on public.posts;
create policy posts_delete_own
  on public.posts for delete
  using (auth.uid() = user_id);

-- comments ------------------------------------------------------------------

drop policy if exists comments_select_public on public.comments;
create policy comments_select_public
  on public.comments for select
  using (true);

drop policy if exists comments_insert_own on public.comments;
create policy comments_insert_own
  on public.comments for insert
  with check (auth.uid() = user_id);

drop policy if exists comments_update_own on public.comments;
create policy comments_update_own
  on public.comments for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists comments_delete_own on public.comments;
create policy comments_delete_own
  on public.comments for delete
  using (auth.uid() = user_id);

-- post_images ---------------------------------------------------------------
-- Ownership is inherited from the parent post. No update policy at all:
-- an image is added or deleted, never mutated.

drop policy if exists post_images_select_public on public.post_images;
create policy post_images_select_public
  on public.post_images for select
  using (true);

drop policy if exists post_images_insert_parent_owner on public.post_images;
create policy post_images_insert_parent_owner
  on public.post_images for insert
  with check (
    exists (
      select 1 from public.posts p
      where p.id = post_id and p.user_id = auth.uid()
    )
  );

drop policy if exists post_images_delete_parent_owner on public.post_images;
create policy post_images_delete_parent_owner
  on public.post_images for delete
  using (
    exists (
      select 1 from public.posts p
      where p.id = post_id and p.user_id = auth.uid()
    )
  );

-- comment_images ------------------------------------------------------------

drop policy if exists comment_images_select_public on public.comment_images;
create policy comment_images_select_public
  on public.comment_images for select
  using (true);

drop policy if exists comment_images_insert_parent_owner on public.comment_images;
create policy comment_images_insert_parent_owner
  on public.comment_images for insert
  with check (
    exists (
      select 1 from public.comments c
      where c.id = comment_id and c.user_id = auth.uid()
    )
  );

drop policy if exists comment_images_delete_parent_owner on public.comment_images;
create policy comment_images_delete_parent_owner
  on public.comment_images for delete
  using (
    exists (
      select 1 from public.comments c
      where c.id = comment_id and c.user_id = auth.uid()
    )
  );

-- storage -------------------------------------------------------------------
-- Upload path convention is {auth.uid()}/{uuid}.{ext} — the first folder
-- segment IS the owner, so ownership is checkable from the object name alone.

drop policy if exists kwentapp_storage_select_public on storage.objects;
create policy kwentapp_storage_select_public
  on storage.objects for select
  using (bucket_id in ('post-images', 'comment-images', 'avatars'));

drop policy if exists kwentapp_storage_insert_own_folder on storage.objects;
create policy kwentapp_storage_insert_own_folder
  on storage.objects for insert
  with check (
    bucket_id in ('post-images', 'comment-images', 'avatars')
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists kwentapp_storage_update_own_folder on storage.objects;
create policy kwentapp_storage_update_own_folder
  on storage.objects for update
  using (
    bucket_id in ('post-images', 'comment-images', 'avatars')
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists kwentapp_storage_delete_own_folder on storage.objects;
create policy kwentapp_storage_delete_own_folder
  on storage.objects for delete
  using (
    bucket_id in ('post-images', 'comment-images', 'avatars')
    and auth.uid()::text = (storage.foldername(name))[1]
  );
