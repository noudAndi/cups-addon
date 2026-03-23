# Changelog

All notable changes to this add-on are documented in this file.

The format is based on Keep a Changelog.

## [2.0.0-rc.2]

### Fixed
- Resolved `webui` validation by using Home Assistant's required placeholder format.
- Removed deprecated add-on config fields/architectures to clear Supervisor warnings.
- Replaced unsupported `avahi-daemon --no-dbus` CLI flag with config-based `enable-dbus=no` to restore Avahi startup.

### Changed
- Updated HP driver installation to pull `hplip` from Alpine edge repositories.
- Clarified documentation around `hpcups` availability depending on Alpine package availability.
- Added a first-start warning in add-on metadata reminding users to change the default admin password before starting.

## [2.0.0-rc.1]

### Added
- Optional Avahi-based mDNS publishing for configured CUPS printers (`enable_avahi`).
- Automatic mDNS service generation from configured CUPS queues.
- CUPS web UI metadata (`webui`) for direct access from Home Assistant.
- Managed `cupsd.conf` template and automatic managed-config updates.

### Changed
- Repository URLs updated to `https://github.com/noudAndi/cups-addon`.
- CUPS startup moved to supervised `s6` service mode.
- Add-on defaults now enforce authenticated CUPS admin access.

## [1.0.0]

### Added
- Initial release of the Home Assistant CUPS Print Server add-on.
