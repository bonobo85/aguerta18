-- ===== SUPABASE — Aguerta 18 =====
-- Exécuter dans le SQL Editor de Supabase

-- Table des profils utilisateurs
create table if not exists profiles (
  id uuid references auth.users primary key,
  username text not null,
  role text not null default 'En attente',
  created_at timestamptz default now()
);

-- Groupes de fiches
create table if not exists record_groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  status text not null default 'active',
  archived_tag text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table record_groups add column if not exists category text;
update record_groups set category = 'gangs' where category is null;
alter table record_groups alter column category set default 'gangs';
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'record_groups_category_check'
  ) then
    alter table record_groups
      add constraint record_groups_category_check
      check (category in ('police','gangs','entreprises'));
  end if;
end $$;

create unique index if not exists record_groups_active_name_idx on record_groups (lower(name)) where status = 'active';

-- Table des fiches et annonces
create table if not exists records (
  id uuid primary key default gen_random_uuid(),
  type text,
  nom text, prenom text, telephone text,
  description text, tags text,
  title text, content text,
  is_announcement boolean default false,
  created_by text,
  created_at timestamptz default now()
);

alter table records add column if not exists group_id uuid references record_groups(id);

-- Activer RLS
alter table profiles enable row level security;
alter table records enable row level security;
alter table record_groups enable row level security;

-- Politiques RLS — Profiles
drop policy if exists "Lecture profils" on profiles;
create policy "Lecture profils" on profiles for select using (auth.uid() is not null);

drop policy if exists "Insérer son profil" on profiles;
create policy "Insérer son profil" on profiles for insert with check (auth.uid() = id);

drop policy if exists "Modifier son profil" on profiles;
create policy "Modifier son profil" on profiles for update using (auth.uid() = id);

-- Permettre aux admins/managers de modifier tous les profils (gestion des rôles)
drop policy if exists "Admin modifier profils" on profiles;
create policy "Admin modifier profils" on profiles for update using (
  exists (
    select 1 from profiles
    where profiles.id = auth.uid()
    and profiles.role in ('Admin','Patron','Co patron','Co-patron','Bras droit')
  )
);

-- Politiques RLS — Groupes de fiches
drop policy if exists "Lecture groupes fiches" on record_groups;
create policy "Lecture groupes fiches" on record_groups for select using (auth.uid() is not null);

drop policy if exists "Managers créer groupes fiches" on record_groups;
create policy "Managers créer groupes fiches" on record_groups for insert with check (
  exists (
    select 1 from profiles
    where profiles.id = auth.uid()
    and profiles.role in ('Admin','Patron','Co patron','Co-patron','Bras droit')
  )
);

drop policy if exists "Managers modifier groupes fiches" on record_groups;
create policy "Managers modifier groupes fiches" on record_groups for update using (
  exists (
    select 1 from profiles
    where profiles.id = auth.uid()
    and profiles.role in ('Admin','Patron','Co patron','Co-patron','Bras droit')
  )
);

drop policy if exists "Managers supprimer groupes fiches" on record_groups;
create policy "Managers supprimer groupes fiches" on record_groups for delete using (
  exists (
    select 1 from profiles
    where profiles.id = auth.uid()
    and profiles.role in ('Admin','Patron','Co patron','Co-patron','Bras droit')
  )
);

-- Politiques RLS — Records
drop policy if exists "Lecture records" on records;
create policy "Lecture records" on records for select using (auth.uid() is not null);

drop policy if exists "Créer records" on records;
create policy "Créer records" on records for insert with check (auth.uid() is not null);

drop policy if exists "Modifier records" on records;
create policy "Modifier records" on records for update using (auth.uid() is not null);

drop policy if exists "Supprimer records" on records;
create policy "Supprimer records" on records for delete using (auth.uid() is not null);
