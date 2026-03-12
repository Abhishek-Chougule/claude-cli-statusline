#!/bin/bash
input=$(cat)

# ── ANSI colors ───────────────────────────────────────────────────────────────
ESC=$'\033'
R="${ESC}[0m"
B="${ESC}[1m"
D="${ESC}[2m"
CY="${ESC}[96m"
GR="${ESC}[92m"
YL="${ESC}[93m"
RD="${ESC}[91m"
MG="${ESC}[95m"
BL="${ESC}[94m"
WH="${ESC}[97m"
GY="${ESC}[90m"
SEP="${GY} │ ${R}"

# ── Parse JSON via python3 ────────────────────────────────────────────────────
_parse() {
python3 -c "
import sys, json
d = json.load(sys.stdin)
cw = d.get('context_window', {})
cu = cw.get('current_usage', {})
co = d.get('cost', {})
m  = d.get('model', {})
print('\t'.join(str(x) for x in [
    m.get('display_name', 'Claude'),
    cu.get('input_tokens', 0),
    cu.get('output_tokens', 0),
    cu.get('cache_read_input_tokens', 0),
    cu.get('cache_creation_input_tokens', 0),
    int(cw.get('used_percentage', 0)),
    int(cw.get('remaining_percentage', 100)),
    cw.get('total_input_tokens', 0),
    cw.get('total_output_tokens', 0),
    co.get('total_cost_usd', 0),
    co.get('total_duration_ms', 0),
    co.get('total_api_duration_ms', 0),
    co.get('total_lines_added', 0),
    co.get('total_lines_removed', 0),
]))
"
}

IFS=$'\t' read -r MODEL INPUT OUTPUT CACHE_READ CACHE_WRITE \
                   CTX_PCT CTX_REM TOT_IN TOT_OUT \
                   COST DURATION_MS API_MS LINES_ADD LINES_DEL \
  < <(echo "$input" | _parse)

# ── Number formatter ──────────────────────────────────────────────────────────
fmt() {
  local n=${1:-0}
  if   (( n >= 1000000 )); then awk "BEGIN{printf \"%.1fM\",$n/1000000}"
  elif (( n >= 1000 ));    then awk "BEGIN{printf \"%.1fk\",$n/1000}"
  else echo "$n"
  fi
}

# ── Duration formatters ───────────────────────────────────────────────────────
fmt_dur() {
  local ms=${1:-0}
  local s=$(( ms / 1000 )) m h
  m=$(( s / 60 )); s=$(( s % 60 ))
  h=$(( m / 60 )); m=$(( m % 60 ))
  if   (( h > 0 )); then printf "%dh%02dm%02ds" $h $m $s
  elif (( m > 0 )); then printf "%dm%02ds" $m $s
  else                   printf "%ds" $s
  fi
}

fmt_ms() {
  local ms=${1:-0}
  if (( ms >= 1000 )); then awk "BEGIN{printf \"%.1fs\",$ms/1000}"
  else echo "${ms}ms"
  fi
}

# ── Context progress bar (12 chars) ───────────────────────────────────────────
BAR_LEN=12
FILLED=$(( CTX_PCT * BAR_LEN / 100 ))
(( FILLED > BAR_LEN )) && FILLED=$BAR_LEN
EMPTY=$(( BAR_LEN - FILLED ))
BAR=""
for (( i=0; i<FILLED; i++ )); do BAR+="█"; done
for (( i=0; i<EMPTY;  i++ )); do BAR+="░"; done

# ── Threshold colours ─────────────────────────────────────────────────────────
if   (( CTX_PCT >= 80 )); then CTX_COL=$RD
elif (( CTX_PCT >= 50 )); then CTX_COL=$YL
else                           CTX_COL=$GR
fi

COST_CENTS=$(awk "BEGIN{printf \"%d\",$COST*100}")
if   (( COST_CENTS >= 50 )); then COST_COL=$RD
elif (( COST_CENTS >= 10 )); then COST_COL=$YL
else                               COST_COL=$GR
fi

# ── Render ─────────────────────────────────────────────────────────────────────
printf "${B}${CY}◆ %s${R}"                        "$MODEL"
printf "%s${CTX_COL}%s %d%%${R}"                  "$SEP" "$BAR" "$CTX_PCT"
printf "%s${D}↓${R}${WH}%s${R} ${D}↑${R}${WH}%s${R}" \
                                                   "$SEP" "$(fmt $INPUT)" "$(fmt $OUTPUT)"
printf "%s${D}cache ${R}${YL}r:%s${R}${GY}/${R}${MG}w:%s${R}" \
                                                   "$SEP" "$(fmt $CACHE_READ)" "$(fmt $CACHE_WRITE)"
printf "%s${D}Σ ${R}${BL}%s${R}${GY}/${R}${BL}%s${R}" \
                                                   "$SEP" "$(fmt $TOT_IN)" "$(fmt $TOT_OUT)"
printf "%s${GR}+%s${R}${GY}/${R}${RD}-%s${R}"    "$SEP" "$LINES_ADD" "$LINES_DEL"
printf "%s${D}⚡${R}${WH}%s${R} ${D}⏱${R}${WH}%s${R}" \
                                                   "$SEP" "$(fmt_ms $API_MS)" "$(fmt_dur $DURATION_MS)"
printf "%s${COST_COL}\$%.4f${R} "                 "$SEP" "$COST"
