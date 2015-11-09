load ../node_modules/bats-assert/all

unset NODENV_VERSION
unset NODENV_DIR

NODENV_TEST_DIR="${BATS_TMPDIR}/nodenv"
PLUGIN="${NODENV_TEST_DIR}/root/plugins/nodenv-aliases"

# guard against executing this block twice due to bats internals
if [ "$NODENV_ROOT" != "${NODENV_TEST_DIR}/root" ]; then
  export NODENV_ROOT="${NODENV_TEST_DIR}/root"
  export HOME="${NODENV_TEST_DIR}/home"
  local parent

  export INSTALL_HOOK="${BATS_TEST_DIRNAME}/../etc/nodenv.d/install/autoalias.bash"

  PATH=/usr/bin:/bin:/usr/sbin:/sbin
  PATH="${NODENV_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../nodenv/libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../nodenv/test/libexec:$PATH"
  PATH="${NODENV_ROOT}/shims:$PATH"
  export PATH
fi

teardown() {
  rm -rf "$NODENV_TEST_DIR"
}

# Creates fake version directories
create_versions() {
  for v in $*
  do
    #echo "Created version: $d"
    d="$NODENV_TEST_DIR/root/versions/$v"
    mkdir -p "$d/bin"
    echo $v > "$d/RELEASE.txt"
    ln -nfs /bin/echo "$d/bin/node"
  done
}


# assert_alias_version alias version

assert_alias_version() {
  if [ ! -f $NODENV_ROOT/versions/$1/RELEASE.txt ]
  then
    echo "Versions:"
    (cd $NODENV_ROOT/versions ; ls -l)
  fi
  assert_equal "$2" `cat $NODENV_ROOT/versions/$1/RELEASE.txt 2>&1`
}

assert_alias_missing() {
  if [ -f $NODENV_ROOT/versions/$1/RELEASE.txt ]
  then
    assert_equal "no-version" `cat $NODENV_ROOT/versions/$1/RELEASE.txt 2>&1`
  fi
}


assert_line_starts_with() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ -n "${line#${1}}" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}
