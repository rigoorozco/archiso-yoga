#!/usr/bin/env bash
#
# Publish a local ISO build as a GitHub release.

set -euo pipefail

DEFAULT_REPO='rigoorozco/archiso-yoga'

print_help() {
    cat <<EOF
Usage:
    scripts/publish_release.sh [options]

Options:
    -a FILE       ISO or release asset to upload (default: newest out/*.iso)
    -d TEXT       release notes body
    -F FILE       read release notes body from FILE
    -h            print help
    -p            mark the release as a prerelease
    -r REPO       GitHub repository in OWNER/REPO form (default: ${DEFAULT_REPO})
    -t TAG        release tag (default: asset basename without .iso)
    -T TITLE      release title (default: tag)
    -y            do not prompt for confirmation

Environment:
    GH_REPO       override default repository when -r is not set

Examples:
    scripts/publish_release.sh
    scripts/publish_release.sh -a out/archlinux-yoga-2026.08.07-aarch64.iso -t 2026.08.07
    scripts/publish_release.sh -r "${DEFAULT_REPO}" -t 2026.08.07 -F CHANGELOG.rst
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "$1 is required"
}

repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || pwd
}

newest_iso() {
    local -a files=()

    if [[ -d out ]]; then
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find out -maxdepth 1 -type f -name '*.iso' -print0)
    fi

    ((${#files[@]} > 0)) || die "no ISO found under out/. Pass one with -a FILE."

    local newest=${files[0]}
    local file
    for file in "${files[@]}"; do
        if [[ "$file" -nt "$newest" ]]; then
            newest=$file
        fi
    done

    printf '%s\n' "$newest"
}

confirm_release() {
    local repo=$1
    local tag=$2
    local title=$3
    local asset=$4
    local checksum=$5

    cat <<EOF
About to publish GitHub release:
  repository: ${repo:-gh default repository}
  tag:        ${tag}
  title:      ${title}
  asset:      ${asset}
  checksum:   ${checksum}
EOF

    read -r -p 'Continue? [y/N] ' answer
    [[ "$answer" == 'y' || "$answer" == 'Y' ]]
}

asset=''
body=''
body_file=''
prerelease=0
repo=${GH_REPO:-$DEFAULT_REPO}
tag=''
title=''
yes=0

while getopts ':a:d:F:hpr:t:T:y' opt; do
    case "$opt" in
        a)
            asset=$OPTARG
            ;;
        d)
            body=$OPTARG
            ;;
        F)
            body_file=$OPTARG
            ;;
        h)
            print_help
            exit 0
            ;;
        p)
            prerelease=1
            ;;
        r)
            repo=$OPTARG
            ;;
        t)
            tag=$OPTARG
            ;;
        T)
            title=$OPTARG
            ;;
        y)
            yes=1
            ;;
        :)
            die "option -$OPTARG requires an argument"
            ;;
        \?)
            die "unknown option: -$OPTARG"
            ;;
    esac
done

shift $((OPTIND - 1))
(($# == 0)) || die "unexpected positional arguments: $*"

require_command gh
require_command git
require_command sha256sum

cd "$(repo_root)"

if [[ -z "$asset" ]]; then
    asset=$(newest_iso)
fi

[[ -f "$asset" ]] || die "asset does not exist: $asset"
[[ -z "$body_file" || -f "$body_file" ]] || die "release notes file does not exist: $body_file"

asset_basename=$(basename "$asset")
tag=${tag:-${asset_basename%.iso}}
title=${title:-$tag}
checksum="${asset}.sha256"
checksum_dir=''

cleanup() {
    if [[ -n "$checksum_dir" && -d "$checksum_dir" ]]; then
        rm -rf -- "$checksum_dir"
    fi
}
trap cleanup EXIT

if [[ -w "$(dirname "$asset")" ]]; then
    (
        cd "$(dirname "$asset")"
        sha256sum "$asset_basename" > "$(basename "$checksum")"
    )
else
    checksum_dir=$(mktemp -d)
    checksum="${checksum_dir}/${asset_basename}.sha256"
    (
        cd "$(dirname "$asset")"
        sha256sum "$asset_basename" > "$checksum"
    )
fi

if ((yes == 0)); then
    confirm_release "$repo" "$tag" "$title" "$asset" "$checksum" || die 'release cancelled'
fi

gh_args=(release create "$tag" "$asset" "$checksum" --title "$title")

if [[ -n "$repo" ]]; then
    gh_args+=(--repo "$repo")
fi

if [[ -n "$body_file" ]]; then
    gh_args+=(--notes-file "$body_file")
elif [[ -n "$body" ]]; then
    gh_args+=(--notes "$body")
else
    gh_args+=(--generate-notes)
fi

if ((prerelease == 1)); then
    gh_args+=(--prerelease)
fi

gh "${gh_args[@]}"
