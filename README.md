# Cloudflare::DNS::Update

This gem provides a simple executable tool for managing Cloudflare records to provide dynamic DNS like functionality. You need to add it to whatever `cron` system your host system uses.

[![Build Status](https://secure.travis-ci.org/ioquatix/cloudflare-dns-update.svg)](http://travis-ci.org/ioquatix/cloudflare-dns-update)
[![Coverage Status](https://coveralls.io/repos/socketry/cloudflare-dns-update/badge.svg)](https://coveralls.io/r/socketry/cloudflare-dns-update)

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

## See Also

- [cloudflare](https://github.com/ioquatix/cloudflare) – Provides access to Cloudflare.

## License

Released under the MIT license.

Copyright, 2017, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
