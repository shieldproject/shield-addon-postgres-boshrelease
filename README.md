# SHIELD PostgreSQL Add-on

This BOSH release provides add-on tools for augmenting SHIELD
Agents with various versions of the PostgreSQL command-line
utilities for backup and restore: psql, pg_dump, and pg_dumpall.

## Versions

The following versions are currently available:

 - **18.3**   via `shield-addon-postgres-18`
 - **17.9**   via `shield-addon-postgres-17`
 - **16.13**  via `shield-addon-postgres-16`
 - **15.17**  via `shield-addon-postgres-15`
 - **14.22**  via `shield-addon-postgres-14`
 - **13.23**  via `shield-addon-postgres-13`
 - **11.22**  via `shield-addon-postgres-11`
 - **10.23**  via `shield-addon-postgres-10`
 - **9.6.24** via `shield-addon-postgres-9.6`

Need a version we don't (yet) support?  Open a [Github Issue][bug]
asking that we package it up.  If possible, supply both the full
version, and a link to the canonical (postgresql.org) download
page.

## Using this BOSH Release

**Note:** This BOSH release is not intended to stand on its own.
It exists to augment the `shield-agent` job of the [SHIELD BOSH
Release][1], and only in cases where the psql / pg\_dump\* utilities
are missing.

To colocate this BOSH release with your shield-agent instance
group, just add a new job to the group:

```yaml
instance_groups:
  - name: whatever
    jobs:
      # ...
      - name:    shield-addon-postgres-9.6
        release: shield-addon-postgres
```

That's really all there is to it.

[bug]: https://github.com/shieldproject/shield-addon-postgres-boshrelease/issues
[1]:   https://github.com/shieldproject/shield-boshrelease
