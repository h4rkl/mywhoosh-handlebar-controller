#!/bin/sh

set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

docker run --rm \
    -v "$project_dir:/workspace" \
    -w /workspace \
    zmkfirmware/zmk-build-arm:stable \
    sh -eu -c '
        zmk_workspace=/workspace/build/zmk-workspace
        mkdir -p "$zmk_workspace" /workspace/build/firmware
        rm -rf "$zmk_workspace/config"
        mkdir -p "$zmk_workspace/config"
        cp -R /workspace/config/. "$zmk_workspace/config/"

        cd "$zmk_workspace"
        if [ ! -d .west ]; then
            west init -l config
        fi
        west update --fetch-opt=--filter=tree:0
        west zephyr-export

        build_variant() {
            shield_name=$1
            artifact_name=$2
            build_dir="/workspace/build/$shield_name"

            west build -p always -s zmk/app -d "$build_dir" -b nice_nano_v2 -- \
                -DZMK_CONFIG="$zmk_workspace/config" \
                -DSHIELD="$shield_name" \
                -DZMK_EXTRA_MODULES=/workspace
            cp "$build_dir/zephyr/zmk.uf2" "/workspace/build/firmware/$artifact_name.uf2"
        }

        build_variant mywhoosh_two_button mywhoosh-two-button
        build_variant mywhoosh_four_button mywhoosh-four-button
        build_variant settings_reset nice-nano-settings-reset
    '

printf '%s\n' "Firmware written to $project_dir/build/firmware"
