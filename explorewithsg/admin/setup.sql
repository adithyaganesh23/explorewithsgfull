-- ============================================
-- Explore with SG — Supabase Database Schema
-- Run this entire file in:
-- Supabase Dashboard > SQL Editor > New query > Paste > Run
-- ============================================

-- 1. DRIVERS
create table if not exists drivers (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  phone            text not null,
  whatsapp         text,
  vehicle_model    text not null,
  reg_number       text not null,
  seats            integer not null,
  vehicle_type     text not null default 'SUV',
  availability     text not null default 'free'
                   check (availability in ('free','on_trip','off_duty')),
  notes            text,
  created_at       timestamptz default now()
);

-- 2. PACKAGES
create table if not exists packages (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  type             text not null default 'travel'
                   check (type in ('travel','corporate')),
  price            text not null,
  duration         text,
  max_pax          integer,
  description      text,
  tags             text[],
  is_featured      boolean default false,
  is_live          boolean default false,
  created_at       timestamptz default now()
);

-- 3. ENQUIRIES
create table if not exists enquiries (
  id               uuid primary key default gen_random_uuid(),
  customer_name    text not null,
  customer_phone   text not null,
  service_type     text not null
                   check (service_type in ('travel','corporate','custom')),
  destination      text,
  travel_date      date,
  group_size       integer,
  status           text not null default 'new'
                   check (status in ('new','in_progress','confirmed','closed')),
  driver_id        uuid references drivers(id) on delete set null,
  notes            text,
  created_at       timestamptz default now()
);

-- 4. BOOKINGS
create table if not exists bookings (
  id               uuid primary key default gen_random_uuid(),
  ref              text unique not null
                   default 'BK-' || upper(substr(gen_random_uuid()::text, 1, 6)),
  enquiry_id       uuid references enquiries(id) on delete cascade,
  driver_id        uuid references drivers(id) on delete set null,
  status           text not null default 'confirmed'
                   check (status in ('confirmed','on_route','completed','cancelled')),
  driver_notes     text,
  created_at       timestamptz default now()
);

-- Indexes
create index if not exists idx_enquiries_status     on enquiries(status);
create index if not exists idx_enquiries_driver     on enquiries(driver_id);
create index if not exists idx_enquiries_date       on enquiries(travel_date);
create index if not exists idx_bookings_date        on bookings(created_at);
create index if not exists idx_drivers_availability on drivers(availability);

-- Row Level Security (allow anon key full access for now)
alter table drivers    enable row level security;
alter table packages   enable row level security;
alter table enquiries  enable row level security;
alter table bookings   enable row level security;

create policy "anon full access drivers"
  on drivers for all to anon using (true) with check (true);
create policy "anon full access packages"
  on packages for all to anon using (true) with check (true);
create policy "anon full access enquiries"
  on enquiries for all to anon using (true) with check (true);
create policy "anon full access bookings"
  on bookings for all to anon using (true) with check (true);

-- Sample drivers
insert into drivers (name, phone, whatsapp, vehicle_model, reg_number, seats, vehicle_type, availability) values
  ('Suresh Kumar',   '+91 98401 11111', '+91 98401 11111', 'Toyota Innova Crysta', 'TN 09 AB 1234', 7,  'SUV',   'on_trip'),
  ('Arjun Muthu',    '+91 98402 22222', '+91 98402 22222', 'Maruti Swift Dzire',   'TN 07 CD 5678', 4,  'Sedan', 'on_trip'),
  ('Rajan Pillai',   '+91 98403 33333', '+91 98403 33333', 'Tempo Traveller',      'TN 11 EF 9012', 12, 'Tempo', 'free'),
  ('Murugan D.',     '+91 98404 44444', '+91 98404 44444', 'Toyota Innova Crysta', 'TN 03 GH 3456', 7,  'SUV',   'on_trip'),
  ('Balan Krishnan', '+91 98405 55555', '+91 98405 55555', 'Maruti Ertiga',        'TN 05 IJ 7890', 6,  'MPV',   'free'),
  ('Vinoth Nair',    '+91 98406 66666', '+91 98406 66666', 'Toyota Innova',        'TN 22 KL 2345', 7,  'SUV',   'free'),
  ('Prasad S.',      '+91 98407 77777', '+91 98407 77777', 'Tempo Traveller',      'TN 14 MN 6789', 14, 'Tempo', 'free');

-- Sample packages
insert into packages (name, type, price, duration, max_pax, description, tags, is_featured, is_live) values
  ('Ooty 3-day getaway',    'travel',    '4500',  '3 days · 2 nights', 8,  'Hill station escape with meals and sightseeing',        ARRAY['Hill station','Meals incl.','Group'], true,  true),
  ('Pondicherry day trip',  'travel',    '1800',  '1 day',             6,  'Beach town day trip with guided tour',                  ARRAY['Beach','Day trip'],                   false, true),
  ('Kodaikanal 2-day',      'travel',    '3200',  '2 days · 1 night',  12, 'Misty hills retreat with waterfall visits',             ARRAY['Hill station','Meals incl.'],         false, true),
  ('Mysore heritage tour',  'travel',    '2900',  '2 days · 1 night',  10, 'Palace, zoo and silk market tour',                      ARRAY['Heritage','Group'],                   false, true),
  ('Mahabalipuram day',     'travel',    '1500',  '1 day',             6,  'Shore temples and beach',                               ARRAY['Temple','Beach'],                     false, false),
  ('Daily office commute',  'corporate', '12000', 'Monthly',           4,  'Fixed route daily office commute on monthly contract',  ARRAY['Fixed route','Monthly'],              true,  true),
  ('Airport transfer plan', 'corporate', '2200',  'Per trip',          6,  'Reliable airport pickup and drop service',              ARRAY['Airport','On-demand'],                false, true),
  ('Team outing plan',      'corporate', '6500',  'Per trip',          14, 'Group transport for corporate team outings',            ARRAY['Group'],                              false, false);

-- Sample enquiries
insert into enquiries (customer_name, customer_phone, service_type, destination, travel_date, group_size, status, created_at) values
  ('Meena Krishnan',    '+91 98401 23456', 'travel',    'Kodaikanal',  '2026-05-02', 6,  'new',         now() - interval '2 days'),
  ('Vijay Raghavan',    '+91 99401 78901', 'corporate', 'Weekly taxi', '2026-04-14', 3,  'new',         now() - interval '1 day'),
  ('Sunitha S.',        '+91 97401 34567', 'travel',    'Ooty',        '2026-04-20', 10, 'new',         now() - interval '1 day'),
  ('Prakash Kumar',     '+91 96401 56789', 'custom',    'Custom trip', '2026-05-05', 4,  'in_progress', now() - interval '4 hours'),
  ('Lakshmi Narayanan', '+91 95401 90123', 'travel',    'Pondicherry', '2026-04-18', 3,  'in_progress', now() - interval '2 hours'),
  ('S. Krishnamurthy',  '+91 94401 12345', 'travel',    'Pondicherry', '2026-04-09', 8,  'confirmed',   now() - interval '1 day');
