# Pretix deploy — Fyneo billetterie events

Image Pretix custom (vanilla `pretix/standalone:stable` + plugins `pretix-mollie` + `pretix-oidc`) déployée via Coolify Hostinger projet `fyneo-ops`.

## Stack

- Pretix self-host AGPL — billetterie events physiques
- Postgres 16-alpine — DB
- Redis 7-alpine — sessions + Celery broker
- Plugins :
  - `pretix-mollie` (paiements via Mollie, plugin officiel Pretix org)
  - `pretix-oidc` (SSO Authentik via OIDC, plugin community adevolutio)

## Domaine

`tickets.fyneo.org` (CNAME Cloudflare → Coolify Hostinger VPS)

## Doctrine

Hostinger Coolify (pas Scaleway Dokploy) — data ponctuelle event séminaire, paiements off-loaded Mollie (PCI hors Pretix DB), RGPD rétention 24mo. Voir `feedback_dual_paas_canon.md`.

## Setup Coolify UI (étapes)

1. **Repo Git** : push ce dossier vers GitHub privé `davidlinfr/pretix-deploy` (branche `main`)
2. **Coolify** projet `fyneo-ops` :
   - Add Resource → Public/Private Repository (Docker Compose)
   - Source : GitHub repo `davidlinfr/pretix-deploy`
   - Branch : `main`
   - Compose file : `docker-compose.yml`
   - Build pack : Dockerfile
3. **Environment Variables** (Coolify UI Environment tab) :
   - `POSTGRES_DB=pretix`
   - `POSTGRES_USER=pretix`
   - `POSTGRES_PASSWORD=<gen openssl rand -base64 32>`
   - `DJANGO_SECRET=<gen openssl rand -base64 64>`
   - `SMTP_HOST=smtp.azurecomm.net` (ou autre — vérifier compte ACS)
   - `SMTP_PORT=587`
   - `SMTP_USER=<acs-user>`
   - `SMTP_PASSWORD=<acs-password>`
4. **Domain** : `tickets.fyneo.org` (Coolify auto-génère cert Let's Encrypt)
5. **DNS Cloudflare** zone `fyneo.org` :
   - Type CNAME, name `tickets`, target `<vps-hostinger-fqdn>` ou IP A record
   - Proxied (orange cloud) ON
6. **Deploy** → attendre build (~5-10 min première fois pour install plugins pip)

## Post-deploy

1. Login admin Pretix → `https://tickets.fyneo.org/control/`
2. Créer admin user (email David)
3. Settings → API tokens → Create token (scope team Fyneo Admin)
4. Sauver token : `~/.claude/secrets/api-keys.json` clé `pretix.api_token`
5. Plugins → activer `pretix-mollie` + `pretix-oidc` au niveau event
6. Mollie config : Event settings → Payment → Mollie → API key live + profile ID
7. OIDC config : voir doc plugin (provider Authentik `auth.fyneo.org`)
8. Créer organizer `fyneo` + event `seminaire-margue-juin-2026` per `pretix-config.md`

## Refs

- Plan : `~/.claude/plans/tu-chercais-les-meilleurs-greedy-lark.md`
- Config canon : `~/Obsidian/20_PROJETS/Seminaire Juin/pretix-config.md`
- Skill API : `~/Obsidian/.claude/skills/pretix-cli/SKILL.md`
- Pretix docs : https://docs.pretix.eu/
- Plugin Mollie : https://github.com/pretix/pretix-mollie
- Plugin OIDC : https://github.com/adevolutio/pretix-oidc
