-- ============================================================
-- Explore with SG — Supabase Database Setup
-- Run this entire script once in:
-- Supabase Dashboard → SQL Editor → New query → Paste → Run
-- ============================================================


-- ── DRIVERS ──────────────────────────────────────────────────
create table if not exists drivers (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  phone         text not null,
  whatsapp      text,
  vehicle_model text not null,
  reg_number    text not null,
  seats         integer not null default 4,
  vehicle_type  text not null default 'SUV',
  availability  text not null default 'free'
                check (availability in ('free','on_trip','off_duty')),
  notes         text,
  created_at    timestamptz default now()
);


-- ── PACKAGES ─────────────────────────────────────────────────
create table if not exists packages (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  type        text not null default 'travel'
              check (type in ('travel','corporate')),
  price       text not null,
  duration    text,
  max_pax     integer,
  description text,
  tags        text,
  is_live     boolean not null default false,
  is_featured boolean not null default false,
  created_at  timestamptz default now()
);


-- ── ENQUIRIES ────────────────────────────────────────────────
create table if not exists enquiries (
  id               uuid primary key default gen_random_uuid(),
  customer_name    text not null,
  customer_phone   text not null,
  service_type     text not null,
  destination      text,
  travel_date      date,
  group_size       integer,
  status           text not null default 'new'
                   check (status in ('new','in_progress','confirmed','closed')),
  driver_id        uuid references drivers(id) on delete set null,
  notes            text,
  created_at       timestamptz default now()
);


-- ── ROW LEVEL SECURITY ───────────────────────────────────────
-- Allow anon key full access (your admin panel uses the anon key).
-- Once you add Supabase Auth, tighten these policies.
alter table drivers    enable row level security;
alter table packages   enable row level security;
alter table enquiries  enable row level security;

create policy "anon full access drivers"   on drivers    for all using (true) with check (true);
create policy "anon full access packages"  on packages   for all using (true) with check (true);
create policy "anon full access enquiries" on enquiries  for all using (true) with check (true);


-- ── SEED DATA — sample drivers ───────────────────────────────
insert into drivers (name, phone, whatsapp, vehicle_model, reg_number, seats, vehicle_type, availability) values
  ('Suresh Kumar',   '+91 98401 11111', '+91 98401 11111', 'Toyota Innova Crysta', 'TN 09 AB 1234', 7,  'SUV',   'on_trip'),
  ('Arjun Muthu',    '+91 98402 22222', '+91 98402 22222', 'Maruti Swift Dzire',   'TN 07 CD 5678', 4,  'Sedan', 'on_trip'),
  ('Rajan Pillai',   '+91 98403 33333', '+91 98403 33333', 'Tempo Traveller',      'TN 11 EF 9012', 12, 'Tempo', 'free'),
  ('Murugan D.',     '+91 98404 44444', '+91 98404 44444', 'Toyota Innova Crysta', 'TN 03 GH 3456', 7,  'SUV',   'on_trip'),
  ('Balan Krishnan', '+91 98405 55555', '+91 98405 55555', 'Maruti Ertiga',        'TN 05 IJ 7890', 6,  'MPV',   'free'),
  ('Vinoth Nair',    '+91 98406 66666', '+91 98406 66666', 'Toyota Innova',        'TN 22 KL 2345', 7,  'SUV',   'free'),
  ('Prasad S.',      '+91 98407 77777', '+91 98407 77777', 'Tempo Traveller',      'TN 14 MN 6789', 14, 'Tempo', 'free');


-- ── SEED DATA — sample packages ──────────────────────────────
insert into packages (name, type, price, duration, max_pax, description, tags, is_live, is_featured) values
  ('Ooty 3-day getaway',    'travel',    '₹4,500 / person', '3 days · 2 nights', 8,  'Scenic hill station trip with hotel stays and sightseeing.', 'Hill station,Meals incl.,Group', true,  true),
  ('Pondicherry day trip',  'travel',    '₹1,800 / person', '1 day',             6,  'French quarter, beaches and ashram visit.',                  'Beach,Day trip',                true,  false),
  ('Kodaikanal 2-day',      'travel',    '₹3,200 / person', '2 days · 1 night',  12, 'Misty lakes, forest walks and local cuisine.',               'Hill station,Meals incl.',      true,  false),
  ('Mysore heritage tour',  'travel',    '₹2,900 / person', '2 days · 1 night',  10, 'Palace, zoo, Chamundi Hills and silk market.',               'Heritage,Group',                true,  false),
  ('Mahabalipuram day',     'travel',    '₹1,500 / person', '1 day',             6,  'Shore temples, mahabalipuram carvings and beach.',           'Temple,Beach',                  false, false),
  ('Daily office commute',  'corporate', '₹12,000 / month', 'Monthly contract',  4,  'Fixed route daily pickup and drop for office staff.',        'Fixed route,Monthly',           true,  true),
  ('Airport transfer plan', 'corporate', '₹2,200 / trip',   'Per trip',          6,  'Reliable airport pickups and drops, 24/7.',                  'Airport,On-demand',             true,  false),
  ('Team outing plan',      'corporate', '₹6,500 / trip',   'Per trip',          14, 'Large group transport for corporate outings.',               'Group',                         false, false);


-- ── SEED DATA — sample enquiries ─────────────────────────────
insert into enquiries (customer_name, customer_phone, service_type, destination, travel_date, group_size, status, created_at) values
  ('Meena Krishnan',    '+91 98401 23456', 'Travel package', 'Kodaikanal',   '2026-05-02', 6,  'new',         now() - interval '2 days'),
  ('Vijay Raghavan',    '+91 99401 78901', 'Corporate taxi', 'Weekly commute','2026-04-14', 3,  'new',         now() - interval '1 day'),
  ('Sunitha S.',        '+91 97401 34567', 'Travel package', 'Ooty',         '2026-04-20', 10, 'new',         now() - interval '1 day'),
  ('Prakash Kumar',     '+91 96401 56789', 'Custom trip',    'TBD',          '2026-05-05', 4,  'in_progress', now() - interval '4 hours'),
  ('Lakshmi Narayanan', '+91 95401 90123', 'Travel package', 'Pondicherry',  '2026-04-18', 3,  'in_progress', now() - interval '2 hours'),
  ('S. Krishnamurthy',  '+91 94401 12345', 'Travel package', 'Pondicherry',  '2026-04-09', 8,  'confirmed',   now() - interval '1 day');
