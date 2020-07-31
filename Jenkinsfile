#!groovy
@Library('sfdx-core-ci-lib@development-docker')
import SfdxProjectBuilder
new SfdxProjectBuilder(this).doNotBuildPackage().setNumberOfBuildsToKeep(20).execute()