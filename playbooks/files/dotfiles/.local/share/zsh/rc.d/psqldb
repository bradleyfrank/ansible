#
# Opens a SSH tunnel to [proxy host] and connects to psql.
# Author: Brad Frank
# Date: Feb 2022
# Tested: zsh 5.8 (x86_64-apple-darwin19.6.0)
#

psqldb() {
  local proxy db_env_vars; proxy="$1"
  [[ -z $proxy ]] && { echo "Usage: psqldb [proxy host]" >&2; return 1; }
  [[ -z $DB_HOST || -z $DB_PASSWORD || -z $DB_USER ]] && kdb
  ssh -T "$proxy" || { echo "Can't reach proxy host."; return 1; }
  ssh -M -S "$DB_HOST" -fNL "5432:${DB_HOST}:5432" "$proxy"
  PGPASSWORD="$DB_PASSWORD" psql -h localhost -U "$DB_USER"
  ssh -S "$DB_HOST" -O exit "$proxy"
  db_env_vars=( "${(f)$(env | grep --extended-regexp --only-matching '^DB_[A-Z]+')}" )
  for db_env_var in "${db_env_vars[@]}"; do unset "$db_env_var"; done
}
