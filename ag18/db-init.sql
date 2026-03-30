-- ===== SUPABASE — Aguerta 18 =====
-- Exécuter dans le SQL Editor de Supabase

-- Table des profils utilisateurs
create table if not exists profiles (
  id uuid references auth.users primary key,
  username text not null,
  email text not null,
  role text not null default 'En attente',
  created_at timestamptz default now()
);

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

-- Activer RLS
alter table profiles enable row level security;
alter table records enable row level security;

-- Politiques RLS — Profiles
create policy "Lecture profils" on profiles for select using (auth.uid() is not null);
create policy "Insérer son profil" on profiles for insert with check (auth.uid() = id);
create policy "Modifier son profil" on profiles for update using (auth.uid() = id);

-- Permettre aux admins/managers de modifier tous les profils (gestion des rôles)
create policy "Admin modifier profils" on profiles for update using (
  exists (
    select 1 from profiles
    where profiles.id = auth.uid()
    and profiles.role in ('Admin','Patron','Co patron','Co-patron','Bras droit')
  )
);

-- Politiques RLS — Records
create policy "Lecture records" on records for select using (auth.uid() is not null);
create policy "Créer records" on records for insert with check (auth.uid() is not null);
create policy "Modifier records" on records for update using (auth.uid() is not null);
create policy "Supprimer records" on records for delete using (auth.uid() is not null);
