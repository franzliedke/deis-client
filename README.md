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
- [ ] Applications
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
- [ ] Containers
  - [x] **list all containers**
  - [ ] list all containers by type
  - [ ] restart all containers
  - [ ] restart containers by type
  - [ ] restart containers by type and number
  - [ ] scale containers
- [ ] Configuration
  - [x] **list application configuration**
  - [ ] create new config
  - [ ] unset config variable
- [ ] Domains
  - [x] **list application domains**
  - [ ] add domain
  - [ ] remove domain
- [ ] Builds
  - [x] **list application builds**
  - [x] **create application build**
- [ ] Releases
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
