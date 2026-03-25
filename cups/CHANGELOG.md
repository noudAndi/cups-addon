# Changelog

All notable changes to this add-on are documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

## [2.0.0]

### Added
- Optional Avahi-based mDNS publishing for configured CUPS printers.
- Event-driven service refreshes using inotify.

### Changed
- Stable release of the 2.0 generation.
- Improved CUPS startup and runtime behavior for Home Assistant environments.
- Updated repository metadata and developer tooling for local development.

### Fixed
- Preserved CUPS printers and classes across upgrades and restarts.
- Improved Web UI and add-on configuration compatibility with Home Assistant Supervisor.
- Resolved Avahi startup issues and improved CUPS plus Avahi integration.

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
