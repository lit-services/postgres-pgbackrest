# postgres:18 + pgBackRest — Basis-Image für PITR im Dokploy-DB-Service.
#
# Baut NUR pgBackRest auf das offizielle Postgres-Image drauf; Entrypoint und
# Verhalten bleiben 1:1 wie beim offiziellen `postgres` (docker-entrypoint.sh).
# Es wird hier NICHTS an Betrieb festverdrahtet: archive_mode/archive_command,
# Repo-Ziel (R2), Cipher/Creds kommen zur Laufzeit per Dokploy-Config
# (Custom Command / Env-Vars / gemountete pgbackrest.conf).
ARG PG_MAJOR=18
FROM postgres:${PG_MAJOR}

# pgBackRest aus Debian/pgdg (das offizielle Image bringt den pgdg-Apt-Repo mit).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends pgbackrest; \
    rm -rf /var/lib/apt/lists/*; \
    pgbackrest version

# Config-/Log-Verzeichnisse (dem postgres-User gehörend). Repo-/Spool-Pfad
# setzt die Laufzeit-Config bzw. ein Mount.
RUN set -eux; \
    install -d -o postgres -g postgres -m 0750 /etc/pgbackrest /var/log/pgbackrest
