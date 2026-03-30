# Aguerta 18 — Base de données privée

Application web mono-fichier connectée à **Supabase** (auth + base de données).

## Fonctionnalités

- Inscription / connexion via Supabase Auth (email + mot de passe)
- Fiches : créer, modifier, supprimer, tagger (BCSO, LSPD, Gang, Entreprise, Civils)
- Annonces : publier et gérer des annonces
- Gestion des rôles : Admin, Patron, Co patron, Bras droit, Lieutenant, Élite, Soldat, En attente
- Les admins/patrons peuvent gérer les rôles des utilisateurs
- Recherche instantanée
- Session persistante (auto-reconnexion)

## Mise en place

### 1) Créer un projet Supabase

Sur [supabase.com](https://supabase.com), créer un projet et exécuter le contenu de `db-init.sql` dans le **SQL Editor**.

### 2) Configurer les clés

Dans `index.html`, remplacer les deux constantes en haut du script :

```js
const SUPABASE_URL = 'https://xxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGci...';
```

Les valeurs se trouvent dans **Settings > API** du dashboard Supabase.

### 3) Déployer

Le site est un simple fichier HTML statique. Il peut être hébergé n'importe où :
- Netlify (drag & drop)
- Vercel
- GitHub Pages
- Ou simplement ouvrir `index.html` localement

### 4) Premier admin

Après inscription du premier utilisateur, mettre son rôle à `Admin` manuellement dans Supabase :

```sql
update profiles set role = 'Admin' where email = 'votre@email.com';
```

## Structure

```
index.html    — Application complète (HTML + JS + Tailwind)
db-init.sql   — Schéma SQL + politiques RLS pour Supabase
package.json  — Métadonnées du projet
README.md     — Ce fichier
```
