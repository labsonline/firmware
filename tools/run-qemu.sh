#!/bin/bash

# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

set -e

: "${QEMU_EXEC:=qemu-system-riscv64}"
: "${ACCEL:=tcg,thread=multi}"

: "${BIOS:=./build/firmware/fw_dynamic.bin}"
: "${KERNEL:=./build/kernel/fw_qemu.elf}"

: "${BOOT_DRIVE:=./build/img/busybox-riscv64.img}"

"${QEMU_EXEC}" \
 -uuid $(uuidgen) \
 -accel "${ACCEL}" \
 -machine virt \
 -smp 4 \
 -m 8192 \
 -bios "${BIOS}" \
 -kernel "${KERNEL}" \
 -device virtio-rng \
 -device virtio-balloon \
 -device virtio-net-device,netdev=net0 \
 -netdev user,id=net0,hostname=qemu,hostfwd=tcp::1022-:22 \
 -device virtio-blk-device,drive=hd0 \
 -drive id=hd0,if=none,format=raw,file="${BOOT_DRIVE}" \
 -serial mon:stdio \
 -nographic \
 $@
