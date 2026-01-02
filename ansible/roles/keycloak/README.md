Keyclock
=========

Keycloak install

Requirements
------------

The simplest way to retrieve IAM access token is usage of yc-cli, follow docs to get it

yc iam key create --service-account-name terraform --output key.json --description "This key for DNS-01 challenge"
cat key.json | base64 -w0
