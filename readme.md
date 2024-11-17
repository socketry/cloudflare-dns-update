# Cloudflare::DNS::Update

This gem provides a simple executable tool for managing Cloudflare records to provide dynamic DNS like functionality. You need to add it to whatever `cron` system your host system uses.

[![Development Status](https://github.com/socketry/cloudflare-dns-update/workflows/Test/badge.svg)](https://github.com/socketry/cloudflare-dns-update/actions?workflow=Test)

## Features

  - Token based authorization to minimise risk.
  - Handles both IPv4 and IPv6 with custom commands.
  - Can update any record type with any command output.

## Usage

Please see the [project documentation](https://socketry.github.io/cloudflare-dns-update).

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.

## See Also

  - [cloudflare](https://github.com/ioquatix/cloudflare) – Provides access to Cloudflare.
