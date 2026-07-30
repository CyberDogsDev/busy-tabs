# Busy Tabs

Cyber Dogs AI internal team-presence app for macOS. A menu bar dot shows your current
status color; click it to see the whole team's live statuses and change yours.

- Native Swift/SwiftUI menu bar app (macOS 13+)
- Supabase backend with Realtime — status changes appear on every Mac within ~1s
- Statuses are admin-configurable in the database (name, color, order) — no app update needed
- 60s heartbeat; anyone not seen for 3 minutes shows dimmed as Offline

## Install (teammates)

Paste in Terminal (asks for your Mac password):

```bash
curl -fsSL https://github.com/CyberDogsDev/busy-tabs/releases/latest/download/BusyTabs.pkg -o /tmp/BusyTabs.pkg \
  && sudo installer -pkg /tmp/BusyTabs.pkg -target / \
  && open "/Applications/Busy Tabs.app"
```

First run: click the gray dot in the menu bar, enter your name, pick a status.
Enable "Launch at login" in the panel footer.

## One-time backend setup

1. Create a Supabase project.
2. Paste `supabase/schema.sql` into the SQL editor and run it.
3. Put the project URL and anon (publishable) key into `Sources/BusyTabs/Config.swift`.
4. Build and release (below).

## Admin: managing statuses

Edit the `statuses` table in Supabase Studio (Table Editor):

- `name` — label shown in the picker
- `color` — hex like `#FF3B30` (menu bar dot + list dots)
- `sort_order` — picker ordering
- `is_active` — set false to retire a status without breaking members still on it

Running apps pick up changes live.

## Development

```bash
swift build               # debug build
swift run                 # run from source (env vars below override Config.swift)
./scripts/test.sh         # unit tests (wrapper needed on CLT-only Macs)
```

Env overrides for local dev: `BUSYTABS_SUPABASE_URL`, `BUSYTABS_SUPABASE_ANON_KEY`.

## Release

```bash
VERSION=0.1.0 ./scripts/build-pkg.sh   # -> dist/BusyTabs.pkg
gh release create v0.1.0 dist/BusyTabs.pkg --title "v0.1.0"
```

The install command always pulls the latest release. To update the team, ship a new
release and have everyone re-run the install command.
