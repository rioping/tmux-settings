#!/bin/bash
# Claude Code status line script
# Displays: ctx usage | 5h session usage(reset) | 7d weekly usage

input=$(cat)

# --- Context window (from stdin JSON) ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  ctx_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo "$used_pct")
  ctx_display="ctx:${ctx_int}%"
else
  ctx_display="ctx:--"
fi

# --- Usage limits (from API, cached 60s) ---
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_MAX_AGE=60

# Refresh cache in background if stale (never blocks display)
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
else
  cache_age=$((CACHE_MAX_AGE + 1))
fi

if [ "$cache_age" -ge "$CACHE_MAX_AGE" ]; then
  (
    token=$(security find-generic-password -s "Claude Code-credentials" -a "$(whoami)" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    if [ -n "$token" ]; then
      resp=$(curl -s --max-time 5 \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
      if echo "$resp" | jq -e '.five_hour' >/dev/null 2>&1; then
        echo "$resp" > "$CACHE_FILE"
      fi
    fi
  ) &
fi

# Read from cache (may be slightly stale, but never blocks)
session_display=""
weekly_display=""

if [ -f "$CACHE_FILE" ]; then
  data=$(cat "$CACHE_FILE")

  # 5-hour session
  five_util=$(echo "$data" | jq -r '.five_hour.utilization // empty')
  five_reset=$(echo "$data" | jq -r '.five_hour.resets_at // empty')

  # 7-day all models
  seven_util=$(echo "$data" | jq -r '.seven_day.utilization // empty')

  # Reset time as relative
  reset_display=""
  if [ -n "$five_reset" ] && [ "$five_reset" != "null" ]; then
    reset_epoch=$(date -juf "%Y-%m-%dT%H:%M:%S" "${five_reset%%.*}" +%s 2>/dev/null)
    if [ -n "$reset_epoch" ]; then
      now=$(date +%s)
      diff=$((reset_epoch - now))
      if [ "$diff" -gt 0 ]; then
        hours=$((diff / 3600))
        mins=$(( (diff % 3600) / 60 ))
        if [ "$hours" -gt 0 ]; then
          reset_display="${hours}h${mins}m"
        else
          reset_display="${mins}m"
        fi
      fi
    fi
  fi

  if [ -n "$five_util" ]; then
    five_int=$(printf "%.0f" "$five_util" 2>/dev/null || echo "$five_util")
    if [ -n "$reset_display" ]; then
      session_display="5h:${five_int}%(${reset_display})"
    else
      session_display="5h:${five_int}%"
    fi
  fi

  if [ -n "$seven_util" ]; then
    seven_int=$(printf "%.0f" "$seven_util" 2>/dev/null || echo "$seven_util")
    weekly_display="7d:${seven_int}%"
  fi
fi

# --- Assemble with pipe separator ---
parts=()
[ -n "$ctx_display" ] && parts+=("$ctx_display")
[ -n "$session_display" ] && parts+=("$session_display")
[ -n "$weekly_display" ] && parts+=("$weekly_display")

output=""
for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && output+=" | "
  output+="${parts[$i]}"
done
printf "%s" "$output"
