# deis-client

A Ruby client library for [Deis](http://docs.deis.io/) controllers

## Implementation Status

Please use the [Deis documentation](http://docs.deis.io/en/latest/reference/api-v1.5/) as reference.
The following API endpoints are not yet implemented: (bold entries have priority)

- [ ] Authorization
  - [ ] register new user
  - [x] **login**
  - [ ] cancel account
  - [ ] regenerate token
  - [ ] change password
- [x] Applications
  - [x] **list all applications**
  - [x] **create an application**
  - [x] **destroy an application**
  - [x] **list application details**
  - [x] retrieve application logs
  - [x] run on-off commands
- [ ] Certificates
  - [ ] list all certificates
  - [ ] list certificate details
  - [ ] create certificate
  - [ ] destroy a certificate
- [x] Containers
  - [x] **list all containers**
  - [x] list all containers by type
  - [x] restart all containers
  - [x] restart containers by type
  - [x] restart containers by type and number
  - [x] scale containers
- [x] Configuration
  - [x] **list application configuration**
  - [x] create new config
  - [x] unset config variable
- [x] Domains
  - [x] **list application domains**
  - [x] add domain
  - [x] remove domain
- [x] Builds
  - [x] **list application builds**
  - [x] **create application build**
- [x] Releases
  - [x] **list application releases**
  - [x] **list release details**
  - [x] **rollback release**
- [ ] Keys
  - [ ] list keys
  - [ ] add key to user
  - [ ] remove key from user
- [ ] Permissions
  - [ ] list application permissions
  - [ ] create application permission
  - [ ] remove application permission
  - [ ] grant user administation priviliges
- [ ] Users
  - [ ] list all users


## Versioning

The major and minor version numbers match the version of the [Deis Controller API](http://docs.deis.io/en/latest/reference/api-v1.5/).
The patch version marks the version of the gem itself.
