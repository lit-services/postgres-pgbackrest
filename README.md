# postgres-pgbackrest

Offizielles **`postgres:18`** + **pgBackRest** — nichts weiter. Basis-Image für
**PITR** (Point-in-Time-Recovery) im Dokploy-„Database"-Service, ohne Postgres aus
Dokploy herauszulösen.

## Warum
`archive_command` (`pgbackrest archive-push`) wird von Postgres **im eigenen Container**
ausgeführt — die Binary muss also im Postgres-Image liegen. Das offizielle Image ist
bewusst minimal. Statt es bei jedem Boot per `apt install` nachzurüsten (fragil), wird
pgBackRest **einmal** ins Image gebacken. Ein Sidecar kann nur Base-Backups, nicht das
WAL-Archiving.

## Nutzung in Dokploy
Im Postgres-Service nur das **Image-Feld** umstellen:

```
ghcr.io/lit-services/postgres-pgbackrest:18
```

Alles Betriebliche bleibt Dokploy-Config (nichts davon steckt im Image):
- **Custom Command:** `-c archive_mode=on -c archive_command='pgbackrest --stanza=helfinity archive-push %p'` (+ das bestehende Tuning)
- **Env-Vars:** R2-Keys, Cipher-Passphrase (als `PGBACKREST_*`)
- **Mount:** `pgbackrest.conf` nach `/etc/pgbackrest/`

Base-/Diff-Backups laufen als Host-Timer via `docker exec … pgbackrest backup`
(gleiches Muster wie die bestehende Dump-Kette). Details/Runbook:
[`hosting-platform`](https://github.com/Dropicx/hosting-platform) → `stacks/acme/solo/DB-KURZFRIST.md`.

## Tags
- `18` — aktuelles Postgres 18 + pgBackRest (nutzen)
- `latest` — = `18`
- `18-<sha>` — an den Build gepinnt

## Pflege
Die GitHub-Action baut bei jeder Änderung an `Dockerfile`/Workflow **und wöchentlich**
(Mo 04:00 UTC) neu → zieht `postgres:18`-Minor-Patches + pgBackRest-Updates automatisch.
Bei einem Postgres-Major-Bump `PG_MAJOR` anheben.

> Damit Dokploy ohne Login pullen kann, muss das GHCR-Package **public** sein
> (Org → Packages → `postgres-pgbackrest` → Package settings → Change visibility).
