# Changelog

All notable changes to this add-on are documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

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
