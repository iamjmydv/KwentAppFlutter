# Kwentapp

> **Kwento + App** — a mobile-first blog & forum where stories get told.

**Live demo:** _coming on Day 10_ · **Design:** [Figma — Kwentapp Mobile App Design](https://www.figma.com/design/ZhaxX3vMh0m4yYd7QSzi4u)

## Stack

Flutter · Provider (MVVM) · go_router · Supabase (Auth, Postgres + RLS, Storage) · deployed as Flutter Web

## Features

- [ ] Auth — register (email + password), login, logout
- [ ] Public feed — paginated, multi-image previews, visible logged out
- [ ] Posts — create / view / edit / delete with multiple images
- [ ] Comments — full CRUD with images on every post
- [ ] Profile — photo CRUD, name update

## Architecture

MVVM: `View → ViewModel (ChangeNotifier) → Repository → Service`. Services are the only files that touch Supabase. Full architecture notes, RLS policy matrix, and decisions land here on Day 10.

## Run it

```
flutter pub get
flutter run -d chrome
```

_Built day by day, one feature branch per day._
