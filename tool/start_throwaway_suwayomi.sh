#!/usr/bin/env bash
# ISS-134: start a THROWAWAY Suwayomi for live tests on 127.0.0.1:4590 and
# write the marker test/support/live_server_guard.dart requires.
# Never point live tests at :4567 / 100.71.46.98 (Jane's real server).
# Usage: tool/start_throwaway_suwayomi.sh [start|stop]
set -euo pipefail
NAME=sunfire-test-suwayomi
PORT=4590
IMAGE=ghcr.io/suwayomi/tachidesk:preview
if [[ "${1:-start}" == stop ]]; then docker rm -f "$NAME" >/dev/null 2>&1 || true; exit 0; fi
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" -p 127.0.0.1:$PORT:4567 "$IMAGE" >/dev/null
for _ in $(seq 1 90); do
  if curl -fs -m 3 -X POST -H 'content-type: application/json' \
      -d '{"query":"{ aboutServer { version } }"}' "http://127.0.0.1:$PORT/api/graphql" >/dev/null; then break; fi
  sleep 2
done
curl -fs -m 10 -X POST -H 'content-type: application/json' \
  -d '{"query":"mutation { setGlobalMeta(input:{meta:{key:\"sunfire_throwaway_marker\",value:\"sunfire-throwaway-docker-v1\"}}){ meta { key } } }"}' \
  "http://127.0.0.1:$PORT/api/graphql" >/dev/null
echo "Throwaway Suwayomi ready: SUNFIRE_LIVE_URL=http://127.0.0.1:$PORT"
