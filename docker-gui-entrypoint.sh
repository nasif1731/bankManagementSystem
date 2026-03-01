#!/bin/sh
set -e

echo "Waiting for MySQL server to be ready..."
sleep 15

echo "Initializing database (if needed)..."
if [ -f "ATM_Simulator.sql" ]; then
  mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASSWORD}" < ATM_Simulator.sql 2>/dev/null || echo "Database already initialized"
fi

echo "Starting virtual display and window manager..."
Xvfb "${DISPLAY}" -screen 0 1280x800x24 &
fluxbox >/tmp/fluxbox.log 2>&1 &

echo "Starting VNC server on port ${VNC_PORT}..."
x11vnc -display "${DISPLAY}" -forever -nopw -shared -rfbport "${VNC_PORT}" -localhost >/tmp/x11vnc.log 2>&1 &

echo "Starting noVNC on port ${NOVNC_PORT}..."
websockify --web=/usr/share/novnc/ "${NOVNC_PORT}" localhost:"${VNC_PORT}" >/tmp/novnc.log 2>&1 &

echo "Starting ATM application..."
exec "$@"
