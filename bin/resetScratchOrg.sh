#!/bin/bash
org_alias=$1
sfdx org delete scratch --no-prompt --target-org $org_alias
sfdx org create scratch --definition-file config/project-scratch-def.json --alias $org_alias --set-default --duration-days 2
sfdx shane:github:src:install -c -g apex-enterprise-patterns -r fflib-apex-mocks -p sfdx-source/apex-mocks
sfdx shane:github:src:install -c -g apex-enterprise-patterns -r fflib-apex-common -p sfdx-source/apex-common
sfdx shane:github:src:install -c -g apex-enterprise-patterns -r force-di -p force-di
sfdx shane:github:src:install -c -g apex-enterprise-patterns -r at4dx -p sfdx-source/core
sfdx force source push --forceoverwrite 