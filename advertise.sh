#!/usr/bin/env bash
set -euo pipefail
COMPOSE=(docker compose -p mediaboxlite-arr -f compose.yaml -f compose.override.yaml --env-file compose.env)
checkhealth() {
	local service=$1
	"${COMPOSE[@]}" ps --format json | jq  --arg svc "${service}" 'select(.Service == $svc) | (.Health // "healthy") == "healthy"'
}

wait_for_healthy() {
	local service=$1
	local max_retries=30
	local wait_time=5
	local attempt=1

	# shellcheck disable=2310
	while true; do
	 if [[ "$(checkhealth "${service}")" == "true" ]]; then
			break
		else
			if (( attempt > max_retries )); then
				echo "Service ${service} did not become healthy after $((max_retries * wait_time)) seconds."
				exit 1
			fi
			echo "Waiting for service ${service} to become healthy... (Attempt: ${attempt})"
			sleep "${wait_time}"
			((attempt++))
		fi
	done
	echo "Service ${service} is healthy."
}

declare -A svcs=(
        [filebrowser-ts]=svc:arr-filebrowser
        [jellyfin-ts]=svc:jellyfin
		[plex-ts]=svc:plex
		[prowlarr-ts]=svc:prowlarr
		[radarr-ts]=svc:radarr
		[sonarr-ts]=svc:sonarr
		[lidarr-ts]=svc:lidarr
		[whoami-ts]=svc:whoami
		[qbittorrent-ts]=svc:qbittorrent
		[tautulli-ts]=svc:tautulli
		[syncthing-ts]=svc:syncthing
		[jellyseerr-ts]=svc:jellyseerr
)
for svc in "${!svcs[@]}"; do
	wait_for_healthy "${svc}"
	"${COMPOSE[@]}" exec "${svc}" tailscale serve advertise "${svcs[${svc}]}"
done