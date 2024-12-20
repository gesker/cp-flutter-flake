#!/usr/bin/env just --justfile

default:
  @just --list

host := `uname -a`
host:
  echo {{host}}


flake-update:
  nix flake update --commit-lock-file
  echo "flack updated"

fmt:
  @just fmt-nix
  dprint fmt
  echo 'fmt complete'  

fmt-nix:
  find . -type f -name '*.nix' -print0 | xargs -0 nixfmt -v
  echo 'fmt-nix complete'    

build:
  nix build .#flutter
  echo 'build complete'
