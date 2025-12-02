# Sys573-4-Redux

> ### This repo is currently in alpha and is more or less a skeleton driver

This repo contains lua scripts setup to simulate the functions/features of the Konami System 573 when using [PCSX-Redux](https://github.com/grumpycoders/pcsx-redux).

> **_NOTE_**: The term 'simulate' here does not mean it will emulate the hardware like MAME. The term here means that reading from and writing to System 573 registers will give an approximated feedback of what you might get from the real system. Items like the CD-ROM drive or Digital IO are *not* implemented the same way and should not be considered accurate tests.

Current status of items:

* Watchdog: Skeleton - Disabled by default, will reset the PCSX-Redux emulation with a hard reset if not ticked every few frames.
* Flash: Skeleton - Reading from flash supported. Writing is not yet supported.
* CD-ROM: Not implemented
* HDD (homebrew use only): Not implemented
* PCMCIA Flash: Not implemented
* IO Boards: Not implemented
* Security Carts: Not implemented
* JAMMA: Not Implemented
* JVS: Not Implemented
* ASIC Outputs: Not implemented
* EXT Out: Not Implemented
* Analog In: Not Implemented
