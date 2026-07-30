-- Busy Tabs schema. Run once in the Supabase SQL editor.

create table statuses (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    color text not null, -- hex, e.g. '#34C759'
    sort_order int not null default 0,
    is_active boolean not null default true
);

create table members (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    status_id uuid references statuses (id),
    note text,
    last_seen_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Seed statuses. Edit this table in Supabase Studio to add/rename/recolor —
-- apps pick up changes live, no app update needed.
insert into statuses (name, color, sort_order) values
    ('Available',    '#34C759', 1),
    ('Busy',         '#FF3B30', 2),
    ('In a Meeting', '#FF9500', 3),
    ('Away',         '#FFCC00', 4),
    ('Offline',      '#8E8E93', 5);

-- Shared-key trust model: the whole team uses the anon key baked into the app.
alter table statuses enable row level security;
alter table members enable row level security;

create policy "team can read statuses" on statuses
    for select to anon using (true);

create policy "team can read members" on members
    for select to anon using (true);

create policy "team can join" on members
    for insert to anon with check (true);

create policy "team can update members" on members
    for update to anon using (true) with check (true);

-- Realtime change feeds for both tables.
alter publication supabase_realtime add table statuses, members;
