# Changelog

All notable changes to this add-on are documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

## [2.0.0-rc.9]

### Changed (2.0.0-rc.9)
- Maintenance release: version bump to `2.0.0-rc.9`.

## [2.0.0-rc.8]

### Changed (2.0.0-rc.8)
- Maintenance release: version bump to `2.0.0-rc.8`.

## [2.0.0-rc.7]

### Changed (2.0.0-rc.7)
- Maintenance release: version bump to `2.0.0-rc.7`.

## [2.0.0-rc.6]

### Changed (2.0.0-rc.6)
- Maintenance release: version bump to `2.0.0-rc.6`.

## [2.0.0-rc.5]

### Changed (2.0.0-rc.5)
- Maintenance release: version bump to `2.0.0-rc.5`.

## [2.0.0-rc.4]

### Fixed (2.0.0-rc.4)
- Preserved CUPS printers/classes across upgrades and restarts by saving files to `/data/cups/config` before symlinks are applied.

### Changed (2.0.0-rc.4)
- Replaced per-file symlinks with a single `/etc/cups -> /data/cups/config` symlink for fully persistent CUPS state.

## [2.0.0-rc.3]

### Added (2.0.0-rc.3)
- Added `inotify-tools` to support event-driven AirPrint/Avahi service refreshes.

### Changed (2.0.0-rc.3)
- Updated mDNS service generation to use CUPS printer metadata and only publish shared printers.
- Switched Avahi service refresh from fixed polling to inotify-based updates (with polling fallback).

## [2.0.0-rc.2]

### Fixed (2.0.0-rc.2)
- Resolved `webui` validation by using Home Assistant's required placeholder format.
- Removed deprecated add-on config fields/architectures to clear Supervisor warnings.
- Replaced unsupported `avahi-daemon --no-dbus` CLI flag with config-based `enable-dbus=no` to restore Avahi startup.

### Changed (2.0.0-rc.2)
- Updated HP driver installation to pull `hplip` from Alpine edge repositories.
- Clarified documentation around `hpcups` availability depending on Alpine package availability.
- Added a first-start warning in add-on metadata reminding users to change the default admin password before starting.

## [2.0.0-rc.1]

### Added (2.0.0-rc.1)
- Optional Avahi-based mDNS publishing for configured CUPS printers (`enable_avahi`).
- Automatic mDNS service generation from configured CUPS queues.
- CUPS web UI metadata (`webui`) for direct access from Home Assistant.
- Managed `cupsd.conf` template and automatic managed-config updates.

### Changed (2.0.0-rc.1)
- Repository URLs updated to `https://github.com/noudAndi/cups-addon`.
- CUPS startup moved to supervised `s6` service mode.
- Add-on defaults now enforce authenticated CUPS admin access.

## [1.0.0]

### Added (1.0.0)
- Initial release of the Home Assistant CUPS Print Server add-on.
