#!/usr/bin/env bash
set -euo pipefail

# AP CP4 benchmark runner for SkillSwap Campus.
# Run from the project root: bash dbms/run_ap_benchmark.sh [database_name]
# Defaults to skillswap_campus_ap. Every query is run 3 times with
# EXPLAIN (ANALYZE, BUFFERS). All write tests are rolled back.

DB="${1:-skillswap_campus_ap}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLAN_DIR="$SCRIPT_DIR/plans"
REPORT="$SCRIPT_DIR/05_query_timings.md"
TMP_CSV="$(mktemp)"
mkdir -p "$PLAN_DIR"
: > "$TMP_CSV"

run_read() {
  local id="$1" description="$2" sql="$3"
  local run output ms scan times=()
  : > "$PLAN_DIR/${id}.txt"
  for run in 1 2 3; do
    output="$(psql -X -v ON_ERROR_STOP=1 -d "$DB" <<SQL
EXPLAIN (ANALYZE, BUFFERS)
$sql
SQL
)"
    printf '========== RUN %s ==========\n%s\n\n' "$run" "$output" >> "$PLAN_DIR/${id}.txt"
    ms="$(printf '%s\n' "$output" | awk '/Execution Time:/ {print $(NF-1); exit}')"
    if [[ -z "$ms" ]]; then echo "No Execution Time found for $id run $run" >&2; exit 1; fi
    times+=("$ms")
    scan="$(printf '%s\n' "$output" | sed -E 's/^[[:space:]]*//; s/^->[[:space:]]*//' | grep -E '^(Seq Scan|Index Scan|Index Only Scan|Bitmap Heap Scan|Bitmap Index Scan|Insert on|Update on|Delete on)' | sed -E 's/[[:space:]]+\(cost=.*$//' | awk '!seen[$0]++' | awk '!seen[$0]++ { if (out != "") out = out "; "; out = out $0 } END { print out }' || true)"
    if [[ -z "$scan" ]]; then scan="No scan node"; fi
  done
  local avg
  avg="$(printf '%s\n' "${times[@]}" | awk '{s+=$1} END {printf "%.3f", s/NR}')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "READ" "$description" "${times[0]}" "${times[1]}" "${times[2]}" "$avg|$scan" >> "$TMP_CSV"
  printf 'Completed %-3s average %s ms\n' "$id" "$avg"
}

run_write() {
  local id="$1" description="$2" sql="$3" setup="$4"
  local run output ms scan times=()
  : > "$PLAN_DIR/${id}.txt"
  for run in 1 2 3; do
    output="$(psql -X -q -v ON_ERROR_STOP=1 -d "$DB" <<SQL
BEGIN;
$setup
EXPLAIN (ANALYZE, BUFFERS)
$sql
ROLLBACK;
SQL
)"
    printf '========== RUN %s (transaction rolled back) ==========\n%s\n\n' "$run" "$output" >> "$PLAN_DIR/${id}.txt"
    ms="$(printf '%s\n' "$output" | awk '/Execution Time:/ {print $(NF-1); exit}')"
    if [[ -z "$ms" ]]; then echo "No Execution Time found for $id run $run" >&2; exit 1; fi
    times+=("$ms")
    scan="$(printf '%s\n' "$output" | sed -E 's/^[[:space:]]*//; s/^->[[:space:]]*//' | grep -E '^(Seq Scan|Index Scan|Index Only Scan|Bitmap Heap Scan|Bitmap Index Scan|Insert on|Update on|Delete on)' | sed -E 's/[[:space:]]+\(cost=.*$//' | awk '!seen[$0]++' | awk '!seen[$0]++ { if (out != "") out = out "; "; out = out $0 } END { print out }' || true)"
    if [[ -z "$scan" ]]; then scan="DML plan (no scan node)"; fi
  done
  local avg
  avg="$(printf '%s\n' "${times[@]}" | awk '{s+=$1} END {printf "%.3f", s/NR}')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "WRITE" "$description" "${times[0]}" "${times[1]}" "${times[2]}" "$avg|$scan" >> "$TMP_CSV"
  printf 'Completed %-3s average %s ms (rolled back)\n' "$id" "$avg"
}

# READ queries R1-R13; values below are valid sample parameters from the
# inspected skillswap_campus_ap database.
run_read R1 "Login lookup by email" "SELECT student_id, full_name, email, password_hash, department, year_of_study FROM student WHERE email = 'alice.test@example.com';"
run_read R2 "View student profile" "SELECT student_id, full_name, email, department, year_of_study, created_at FROM student WHERE student_id = 1;"
run_read R3 "Browse all skills" "SELECT skill_id, skill_name, category, description FROM skill ORDER BY category, skill_name;"
run_read R4 "Search skills by name or category" "SELECT skill_id, skill_name, category, description FROM skill WHERE skill_name ILIKE '%' || 'Script' || '%' OR category ILIKE '%' || 'Script' || '%' ORDER BY skill_name;"
run_read R5 "View student's teaching and learning skills" "SELECT ss.student_id, s.skill_id, s.skill_name, s.category, ss.skill_type FROM student_skill ss JOIN skill s ON s.skill_id = ss.skill_id WHERE ss.student_id = 1 ORDER BY ss.skill_type, s.skill_name;"
run_read R6 "Find students who teach a skill" "SELECT st.student_id, st.full_name, st.department, st.year_of_study, s.skill_name, s.category FROM student_skill ss JOIN student st ON st.student_id = ss.student_id JOIN skill s ON s.skill_id = ss.skill_id WHERE ss.skill_id = 1 AND ss.skill_type = 'TEACH' AND st.student_id <> 1 ORDER BY st.full_name;"
run_read R7 "Find students who want to learn a skill" "SELECT st.student_id, st.full_name, st.department, st.year_of_study, s.skill_name FROM student_skill ss JOIN student st ON st.student_id = ss.student_id JOIN skill s ON s.skill_id = ss.skill_id WHERE ss.skill_id = 1 AND ss.skill_type = 'LEARN' ORDER BY st.full_name;"
run_read R8 "Find potential teachers for a student's learning skills" "SELECT learner.student_id AS learner_id, learner.full_name AS learner_name, teacher.student_id AS teacher_id, teacher.full_name AS teacher_name, s.skill_id, s.skill_name, s.category FROM student_skill wanted JOIN student_skill offered ON offered.skill_id = wanted.skill_id AND offered.skill_type = 'TEACH' JOIN student learner ON learner.student_id = wanted.student_id JOIN student teacher ON teacher.student_id = offered.student_id JOIN skill s ON s.skill_id = wanted.skill_id WHERE wanted.student_id = 1 AND wanted.skill_type = 'LEARN' AND teacher.student_id <> learner.student_id ORDER BY s.skill_name, teacher.full_name;"
run_read R9 "View incoming exchange requests" "SELECT er.request_id, er.request_type, er.status, er.created_at, requester.student_id AS requester_id, requester.full_name AS requester_name, recipient.student_id AS recipient_id, recipient.full_name AS recipient_name, requested.skill_name AS requested_skill, offered.skill_name AS offered_skill FROM exchange_request er JOIN student requester ON requester.student_id = er.requester_id JOIN student recipient ON recipient.student_id = er.recipient_id JOIN skill requested ON requested.skill_id = er.requested_skill_id LEFT JOIN skill offered ON offered.skill_id = er.offered_skill_id WHERE er.recipient_id = 2 ORDER BY er.created_at DESC;"
run_read R10 "View requests created by a student" "SELECT er.request_id, er.request_type, er.status, er.created_at, recipient.full_name AS recipient_name, requested.skill_name AS requested_skill, offered.skill_name AS offered_skill FROM exchange_request er JOIN student recipient ON recipient.student_id = er.recipient_id JOIN skill requested ON requested.skill_id = er.requested_skill_id LEFT JOIN skill offered ON offered.skill_id = er.offered_skill_id WHERE er.requester_id = 1 ORDER BY er.created_at DESC;"
run_read R11 "View one exchange request" "SELECT er.request_id, er.request_type, er.status, er.created_at, requester.full_name AS requester_name, recipient.full_name AS recipient_name, requested.skill_name AS requested_skill, offered.skill_name AS offered_skill FROM exchange_request er JOIN student requester ON requester.student_id = er.requester_id JOIN student recipient ON recipient.student_id = er.recipient_id JOIN skill requested ON requested.skill_id = er.requested_skill_id LEFT JOIN skill offered ON offered.skill_id = er.offered_skill_id WHERE er.request_id = 1;"
run_read R12 "View feedback for a request" "SELECT f.feedback_id, f.request_id, f.learner_id, st.full_name AS learner_name, f.rating, f.comment, f.created_at FROM feedback f JOIN student st ON st.student_id = f.learner_id WHERE f.request_id = 1 ORDER BY f.created_at DESC;"
run_read R13 "Average feedback submitted by a student" "SELECT st.student_id, st.full_name, ROUND(AVG(f.rating)::NUMERIC, 2) AS average_rating, COUNT(f.feedback_id) AS total_feedback FROM student st LEFT JOIN feedback f ON f.learner_id = st.student_id WHERE st.student_id = 1 GROUP BY st.student_id, st.full_name;"

# WRITE queries W1-W11. Each run is wrapped in BEGIN/ROLLBACK.
run_write W1 "Register a student" "INSERT INTO student (full_name, email, password_hash, department, year_of_study) VALUES ('CP4 Benchmark Student', 'cp4.benchmark.student@example.com', 'benchmark_hash_only', 'CSE', 2) RETURNING student_id, full_name, email, department, year_of_study;" ""
run_write W2 "Update student profile" "UPDATE student SET full_name = 'CP4 Benchmark Updated', department = 'CSE', year_of_study = 2 WHERE student_id = 4 RETURNING student_id, full_name, department, year_of_study;" ""
run_write W3 "Add a teaching or learning skill" "INSERT INTO student_skill (student_id, skill_id, skill_type) VALUES (4, 4, 'TEACH') ON CONFLICT (student_id, skill_id, skill_type) DO NOTHING RETURNING student_id, skill_id, skill_type;" ""
run_write W4 "Remove a student skill" "DELETE FROM student_skill WHERE student_id = 2 AND skill_id = 1 AND skill_type = 'TEACH' RETURNING student_id, skill_id, skill_type;" ""
run_write W5 "Create a one-way LEARN request" "INSERT INTO exchange_request (requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id) SELECT 1, 2, 'LEARN', 1, NULL WHERE 1 <> 2 AND EXISTS (SELECT 1 FROM student_skill WHERE student_id = 1 AND skill_id = 1 AND skill_type = 'LEARN') AND EXISTS (SELECT 1 FROM student_skill WHERE student_id = 2 AND skill_id = 1 AND skill_type = 'TEACH') RETURNING request_id, requester_id, recipient_id, status;" ""
run_write W6 "Create a MUTUAL skill-exchange request" "INSERT INTO exchange_request (requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id) SELECT 2, 3, 'MUTUAL', 3, 1 WHERE 2 <> 3 AND 3 <> 1 AND EXISTS (SELECT 1 FROM student_skill WHERE student_id = 2 AND skill_id = 3 AND skill_type = 'LEARN') AND EXISTS (SELECT 1 FROM student_skill WHERE student_id = 3 AND skill_id = 3 AND skill_type = 'TEACH') AND EXISTS (SELECT 1 FROM student_skill WHERE student_id = 2 AND skill_id = 1 AND skill_type = 'TEACH') AND EXISTS (SELECT 1 FROM student_skill WHERE student_id = 3 AND skill_id = 1 AND skill_type = 'LEARN') RETURNING request_id, requester_id, recipient_id, status;" ""
run_write W7 "Recipient accepts a pending request" "UPDATE exchange_request SET status = 'ACCEPTED' WHERE request_id = :request_id AND recipient_id = 2 AND status = 'PENDING' RETURNING request_id, status;" "INSERT INTO exchange_request (requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id, status) VALUES (1, 2, 'LEARN', 1, NULL, 'PENDING') RETURNING request_id \\gset"
run_write W8 "Recipient rejects a pending request" "UPDATE exchange_request SET status = 'REJECTED' WHERE request_id = :request_id AND recipient_id = 2 AND status = 'PENDING' RETURNING request_id, status;" "INSERT INTO exchange_request (requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id, status) VALUES (1, 2, 'LEARN', 1, NULL, 'PENDING') RETURNING request_id \\gset"
run_write W9 "Requester cancels a pending request" "UPDATE exchange_request SET status = 'CANCELLED' WHERE request_id = :request_id AND requester_id = 1 AND status = 'PENDING' RETURNING request_id, status;" "INSERT INTO exchange_request (requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id, status) VALUES (1, 2, 'LEARN', 1, NULL, 'PENDING') RETURNING request_id \\gset"
run_write W10 "Participant completes an accepted exchange" "UPDATE exchange_request SET status = 'COMPLETED' WHERE request_id = 2 AND status = 'ACCEPTED' AND (requester_id = 1 OR recipient_id = 1) RETURNING request_id, status;" ""
run_write W11 "Submit feedback for a completed exchange" "INSERT INTO feedback (request_id, learner_id, rating, comment) SELECT er.request_id, 1, 5, 'CP4 benchmark feedback' FROM exchange_request er WHERE er.request_id = :request_id AND er.status = 'COMPLETED' AND (er.requester_id = 1 OR er.recipient_id = 1) RETURNING feedback_id, request_id, learner_id, rating, comment;" "INSERT INTO exchange_request (requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id, status) VALUES (1, 2, 'LEARN', 1, NULL, 'COMPLETED') RETURNING request_id \\gset"

# Construct the official AP CP4 timing table.
{
  echo "# CP4 – AP Query Timings"
  echo
  echo "**Project:** SkillSwap Campus  **Database:** \`$DB\`  **PostgreSQL:** $(psql -X -d "$DB" -Atc 'SHOW server_version;' | head -n1)"
  echo
  echo "## Methodology"
  echo
  echo "Each of the 24 application queries from \`dbms/04_queries.sql\` was executed three times with \`EXPLAIN (ANALYZE, BUFFERS)\`. The average is the arithmetic mean of the three reported Execution Time values. Raw plans are saved as one file per query in \`dbms/plans/\`. All WRITE tests were run inside \`BEGIN; ... ROLLBACK;\`. For W7–W9, a valid pending request was inserted inside the same transaction before timing the corresponding status update. For W11, a temporary completed request was inserted before timing feedback submission. The setup rows and the measured write were rolled back together."
  echo
  echo "**Test data parameters:** Alice (student 1), Bob (2), Cara (3), David (4); skill IDs 1–4 (JavaScript, Python, React, Node.js). R1 used Alice's email. W5 used the valid Alice-to-Bob JavaScript LEARN path; W6 used Bob/Cara's mutual React/JavaScript path."
  echo
  echo "**Important:** W1 uses a synthetic email and placeholder hash solely for database execution timing; application password hashing remains the backend's responsibility."
  echo
  echo "## Timing results"
  echo
  echo "| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |"
  echo "|---|---|---|---:|---:|---:|---:|---|"
  while IFS=$'\t' read -r id type desc t1 t2 t3 tail; do
    avg="${tail%%|*}"
    scan="${tail#*|}"
    printf '| %s | %s | %s | %s | %s | %s | %s | %s |\n' "$id" "$type" "$desc" "$t1" "$t2" "$t3" "$avg" "$scan"
  done < "$TMP_CSV"
  echo
  echo "## Raw execution plans"
  echo
  echo "See \`dbms/plans/R1.txt\` through \`R13.txt\` and \`dbms/plans/W1.txt\` through \`W11.txt\`. Each file contains all three plan runs."
} > "$REPORT"

rm -f "$TMP_CSV"
echo
echo "Benchmark complete. Timing report: $REPORT"
echo "Raw plans: $PLAN_DIR/"
echo "Queries benchmarked: $(find "$PLAN_DIR" -maxdepth 1 -type f -name '*.txt' | wc -l | tr -d ' ')"
