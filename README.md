# Kwentapp

> **Kwento + App** — *kwento* is Tagalog for story. A mobile-first blog and forum where anyone can read, and signed-in users write, discuss, and manage their own kwento.

**Live demo:** _not yet deployed_
**Design:** [Figma — Kwentapp Mobile App Design](https://www.figma.com/design/ZhaxX3vMh0m4yYd7QSzi4u) — Design System frame plus six 390×844 screens in user-flow order

Flutter (Web + Android) · Dart · **Provider** · **go_router** · **Supabase** (Auth · Postgres + RLS · Storage) · **MVVM**

---

## Screenshots

_To be added alongside the deployment._

---

## What it does

| Requirement | Status | Where |
|---|---|---|
| Register — email + password only, no confirm-password field | ✅ | `ui/auth/register/` |
| Login / logout | ✅ | `ui/auth/login/`, `ui/profile/` |
| Public post listing, multi-image previews, **paginated, visible logged out** | ✅ | `ui/feed/` |
| Create post with multiple images | ✅ | `ui/post_editor/` |
| View post with images | ✅ | `ui/post_detail/` |
| Update post — add and delete individual images | ✅ | `ui/post_editor/` |
| Delete post | ✅ | `ui/post_editor/` |
| Comments — add, edit, delete, each with multiple images | ✅ | `ui/post_detail/` |
| Profile — photo upload / replace / remove, name update | ✅ | `ui/profile/` |

Route access is an **allowlist**: `/`, `/post/:id`, `/login`, `/register` are public; everything else requires a session, so any route added later is protected by default. Logged-out users get a sign-in prompt, never a dead button.

---

## Architecture — MVVM with Provider

```
View  ──watches──▶  ViewModel  ──calls──▶  Repository  ──composes──▶  Service  ──▶  Supabase
```

**Nothing above a repository knows Supabase exists.** Services are the only files that import the Supabase client; repositories return models and throw sealed `Failure`s; ViewModels catch those into a sealed state; views switch exhaustively over that state.

```
lib/
├── core/
│   ├── common/        shared widgets — fields, buttons, dialogs, image thumbnails,
│   │                  the EditorImage union, author avatar
│   ├── config/        Supabase url + publishable key
│   ├── di/            MultiProvider graph: client → services → repositories → AuthViewModel
│   ├── error/         sealed Failure + failureMessage()
│   ├── resources/     keys, strings, constants (pageSize, image limits)
│   ├── router/        routes, GoRouter, public-route guard, bottom-nav shell
│   ├── theme/         design tokens; light and dark built from one private _build()
│   └── utils/         validators, relative timestamps, image byte sniffing,
│                      image picking, web-only URL strategy via conditional import
├── data/
│   ├── models/        plain Dart, value equality, no Flutter or Supabase imports
│   ├── repositories/  four interfaces + their Supabase implementations
│   └── services/      auth · database · storage — the only Supabase touchpoints
└── ui/
    ├── auth/          login, register, app-lifetime AuthViewModel
    ├── feed/          paginated feed + post cards
    ├── post_detail/   gallery + comment thread
    ├── post_editor/   one page, create and edit modes
    └── profile/       avatar CRUD, name, log out
```

**Dependency injection** happens once at the root. `MultiProvider` builds `SupabaseClient` → a `Provider` per service → a repository per Supabase surface → an app-lifetime `AuthViewModel`, which the router watches as its `refreshListenable`. Screen ViewModels are created by a `ChangeNotifierProvider` in the route builder, so each is born with its page and disposed with it — a stale feed never survives navigation.

**Why MVVM here.** It is the architecture Flutter's own documentation recommends and the native idiom of the Provider ecosystem. The use-case layer that Clean Architecture adds only earns its keep once domain logic outgrows individual screens, and a four-feature CRUD app does not get there. The discipline that matters is kept either way: a single Supabase touchpoint per surface, sealed failures and states, and everything above the repository testable without a backend.

---

## Data model

Five tables. **Images are rows, not arrays** — so adding or deleting one image is a row operation, ordering is an explicit column, and deletion has an exact manifest of files to clean up.

```
profiles ──┐
           ├── posts ──── post_images
           └── comments ── comment_images
```

`profiles` is keyed by the `auth.users` id and created by a `SECURITY DEFINER` trigger at signup, so the row exists before the app ever reads it. `updated_at` is maintained by a database trigger — a client can forget a timestamp, a trigger cannot.

The feed is one round trip:

```sql
select *, profiles(name, avatar_url),
          post_images(id, storage_path, position),
          comments(count)
from posts order by created_at desc
```

Both SQL files live in [`supabase/`](supabase/) and are **idempotent** — safe to re-run against a fresh project.

---

## Row Level Security

RLS is enabled on all five tables. **16 table policies plus 4 storage policies.**

| Table | select | insert | update | delete |
|---|---|---|---|---|
| `profiles` | `true` | — (trigger only) | own | — (cascade) |
| `posts` | `true` | own | own | own |
| `comments` | `true` | own | own | own |
| `post_images` | `true` | owner of parent post | **none** | owner of parent post |
| `comment_images` | `true` | owner of parent comment | **none** | owner of parent comment |

- **Public `select` everywhere** is the requirement, not an oversight — the feed must be readable signed out.
- **Image rows have no update policy at all.** An image is added or deleted, never mutated. An operation with no policy is denied.
- **`with check` on every update** blocks reassigning a row to another user.
- **Storage ownership is the path.** Files are uploaded to `{auth.uid()}/{uuid}.{ext}`, and the policy reads the owner straight out of the object name — no lookup table, nothing to keep in sync.

### Verified, not asserted

The policies were attacked from a second account, **reading the row back after every attempt**:

| Attempt | HTTP | Actual outcome |
|---|---|---|
| Anonymous reads feed / post / comments / profiles | 200 | readable — the public feed works signed out |
| Anonymous insert into any of the five tables | **401 / 42501** | refused |
| Second user edits another's post | 204 | title **unchanged** |
| Second user deletes another's post | 204 | post **still exists** |
| Second user edits another's comment | 204 | body **unchanged** |
| Second user deletes another's comment | 204 | comment **still exists** |
| Second user edits another's profile | 204 | name **unchanged** |
| Second user uploads into another's storage folder | **400 / AccessDenied** | refused by the path policy |
| Owner reassigns their own post to another user | **403 / 42501** | refused by `with check` |
| Owner edits their own post | 204 | title changed |
| Second user comments on another's post | 201 | allowed — it is a forum, not a lockbox |

> **The trap worth knowing:** PostgREST returns **204 both when a row is updated and when RLS filters it to zero rows.** Asserting on status codes alone would have declared a wide-open table secure. Every row above was confirmed by reading the record back.

---

## Decisions

1. **Images as rows, not an array column.** Per-image add and delete is a row operation, `position` gives explicit ordering, and deletion has an exact list of storage paths to remove. An array would mean rewriting the whole record to drop one image.
2. **Storage path is the ownership record.** `{uid}/{uuid}.{ext}` means the policy can authorise an upload from the object name alone.
3. **Pagination fetches `pageSize + 1`.** The extra row's existence *is* `hasMore` — no `count(*)` on every page, and no race between counting and fetching.
4. **One editor page, two modes.** Create and edit differ by the presence of an id; the mixed existing-URL / new-bytes image list is identical machinery in both.
5. **The image union never reaches the data layer.** `EditorImage` is a UI type; repositories take `keptImageIds` plus raw bytes, so "anything not kept is removed" expresses the diff without leaking a view concern downward.
6. **Image positions are unique and increasing, not contiguous.** New images are allocated above the current maximum. Renumbering the survivors would be the obvious fix and is *impossible by design* — image rows have no update policy. Gaps are harmless: the gallery sorts by position, it never indexes by it.
7. **Deletion is database-first, then storage.** A failure midway leaves an orphaned file — invisible and cleanable — instead of a post referencing an image that no longer exists. Fail toward the harmless outcome.
8. **Profile changes propagate through the joined select.** Renaming writes one row; every feed card and comment reflects it because they all reach the author through a foreign key. No cache to invalidate, no client bookkeeping to get wrong.
9. **Credential errors collapse to one message.** Wrong password and unknown email are indistinguishable to the caller — no account enumeration.
10. **Re-entry guards live on the ViewModel.** Disabling a button is cosmetic: a keyboard submit bypasses it, and a scroll listener past the load-more threshold fires continuously.
11. **`flutter_web_plugins` is reached through a conditional import.** It cannot be imported on Android, so clean web URLs (`/post/abc`, not `/#/post/abc`) do not cost the Android build.
12. **The publishable key is committed deliberately.** It is a project identifier, not a credential — what it can do is decided entirely by RLS, which is why the table above matters. The service-role key, which bypasses RLS, appears nowhere in this repo.

---

## Running it

```bash
flutter pub get
flutter run -d chrome
```

The Supabase url and publishable key ship with committed defaults, so no flags are needed. Both can be overridden without editing the file:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
```

To point it at a fresh Supabase project, run [`supabase/schema.sql`](supabase/schema.sql) then [`supabase/policies.sql`](supabase/policies.sql) in the SQL editor, and turn **Confirm email** off under Authentication → Sign In / Providers.

---

## Deliberately out of scope

- **Realtime** — the feed is paginated, not live. Realtime and offset pagination fight each other: rows inserted at the top shift offsets under a reader on page 3, and solving it properly means cursor-based pagination. Not required, so not built.
- **Edge Functions** — every operation here is CRUD that RLS already secures.
- **Automated tests** — a deliberate trade for the time-boxed window. Verification is a manual matrix plus the raw-request security checks above. The architecture keeps its testable shape regardless: one Supabase touchpoint per surface, sealed states, and nothing above a repository bound to a backend.
- **Offline support** — Supabase has no Firestore-equivalent local persistence. For an offline-first app that alone could decide the backend choice.

---

## Notes

Built one feature branch per day, Conventional Commits, each day merged to `main` — the git log is the process record.
