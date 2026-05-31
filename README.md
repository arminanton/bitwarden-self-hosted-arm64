# Bitwarden Self-host (arm64)

This folder scaffolds a build-and-run setup for Bitwarden self-host (API, Admin, Identity, Secrets Manager) prepared to run on aarch64 hosts. Files are intentionally generic and will build the upstream Bitwarden `server` projects at image build time.

Location
- Project root: `/mnt/devvm/custom/bwhosted`
- Setup files: `/mnt/devvm/custom/bwhosted/setup`
- Persistent data/workspace: `/mnt/devvm/custom/bwhosted/workspace/*`

Goals
- Produce arm64 images for Bitwarden services (no emulation at runtime)
- Keep persistent data under `workspace/` per-service
- Ensure container runtime users match host uids/gids (see notes)
- Provide a single `docker-compose.yml` and build scripts to assemble the stack

Important: where to run builds
- You must build the images on an aarch64 (arm64) machine. These scripts assume native arm64 builds with Podman.
- If you try to build on amd64 without QEMU/emulation it will fail. This repo only *prepares* the files to run on an arm64 host.

Prerequisites (target arm64 host)
- podman >= 3.0 (podman build supports --platform)
- podman-compose or `podman compose` support
- git
- ~2-4 GB RAM per .NET publish operation (build can be heavy)

Quickstart
1. As user `ndsadmin`, copy your license and install id/key into the project:

```sh
cd /mnt/devvm/custom/bwhosted
cp ~/dev/bw-lic.json workspace/license/bw-lic.json
cp ~/dev/bw-inst.md workspace/license/bw-inst.md
# or use the helper script
setup/prepare_license.sh
```

2. (On the arm64 build host) Build the images:

```sh
cd /mnt/devvm/custom/bwhosted
# adjust HOST_UID/GID if your ndsadmin uid/gid are different
export HOST_UID=$(id -u ndsadmin)
export HOST_GID=$(id -g ndsadmin)
setup/build-images.sh
```

This will produce images named `localhost/bitwarden/<service>:${TAG}` (default tag `2026.5.0-arm64`).

3. Start the stack (on the arm64 host):

```sh
# still in /mnt/devvm/custom/bwhosted
setup/start.sh
```

4. Map local domains for convenience (on the host):

Add to `/etc/hosts`:

```
127.0.0.1 api.vm.local admin.vm.local identity.vm.local sm-api.vm.local
```

Now you can open `http://api.vm.local:80`, etc. The `nginx` service proxies to the internal containers.

Notes on UID/GID mapping
- During image build we create a system user (appuser) using the `HOST_UID` and `HOST_GID` build args.
- At container start, `/entrypoint.sh` will re-check `HOST_UID`/`HOST_GID` (as runtime env vars) and recreate the `appuser` if necessary so that files created by the container are owned by your host `ndsadmin` user (or root if you intentionally run as root). Make sure to export `HOST_UID`/`HOST_GID` when running compose if you want consistent ownership.

Secrets Manager / Commercial bits
- `sm-api` (commercial) is included in the compose and build flow but requires the licensed `bitwarden_license` sources or runtime license to operate. Place your `bw-lic.json` into `workspace/license/` before building `sm-api`.

Persistence layout (under `workspace/`)
- `workspace/api/` — app-level workspace for the API service
- `workspace/admin/` — admin service workspace
- `workspace/identity/` — identity server workspace
- `workspace/sm-api/` — secrets manager workdir (commercial)
- `workspace/mssql/` — MSSQL database files (Azure SQL Edge)
- `workspace/nginx/` — nginx confs and certs
- `workspace/license/` — put `bw-lic.json` and `bw-inst.md` here
- `workspace/bwdata/` — optional: for bitwarden.sh compatibility

Troubleshooting
- If a build step fails due to missing commercial sources, ensure `workspace/license/bw-lic.json` is present and that `bitwarden_license` is accessible at build time. You may need to mirror private license sources into the build context or mount them at build time.
- For logs: `podman logs <container>` or `podman ps` to list containers.

Security
- This scaffold uses `azure-sql-edge` for local MSSQL compatibility on arm64. Use hardened production alternatives for real deployments.

Next steps I can do for you
- Re-tag local images as `ghcr.io/bitwarden/...` to let an unmodified `bitwarden.sh` installer succeed
- Add automated nginx TLS (self-signed) configuration
- Expand compose with Events, Icons, Notifications, Attachments, and EventProcessor services

