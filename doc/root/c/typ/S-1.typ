= From The C Programming Language to Theoretical Computer Science

== Section -1: Linux and Tool Chain

#outline()

== Intro

== Virtualization

=== Virtual Machine

=== Full Virtualization & Semi Virtualization

Full Virtualization:

全虚拟化通过软件模拟硬件的架构, 和运行, 效率低

+ qemu
+ bochs

Semi Virtualization:

半虚拟化有硬件提供辅助, 虚拟化运行的指令可以直接发到硬件, 由硬件直接运行, 需要硬件支持, 并且无法跨硬件平台模拟

+ KVM
+ ZEN

=== Hardware Virtualization Support

=== Virtual Box

== Operating System

=== Bootloader

=== Bootstrap

=== Kernel

=== GRUB, Systemd-boot

== GNU/ Linux, Minix, GNU/Hurd, \*BSD, Illumos, Drawin, ...: \*nix (Unix-Like)

=== Distribution

=== Debian, Ubuntu, RHEL, Arch, NixOS, Slackware

=== Root Distribution

=== Why Ubuntu

=== Live CD

=== Bootstrap

=== Installation

=== Partition

=== Partition Table

=== File System

=== Log, CoW, Snapshot

=== User & Group

=== Privilege

=== Root user

=== Sudo

=== Terminal, Shell, Terminal Simulator & `tty/n`

=== FHS

=== home

=== root

=== bin & sbin

=== usr

=== User Commands

=== Sudoer Commands

=== commands, parameters, augments

=== shell tricks, pipeline, i/o redirection

=== Forground & Background

=== Process Suspend

=== signal

=== Terminal Reuse

=== Aliasing

=== SSH

=== Shell substitution

=== Command line Editor

=== Version Control

=== Build System
