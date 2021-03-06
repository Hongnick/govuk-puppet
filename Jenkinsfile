#!/usr/bin/env groovy

REPOSITORY = 'govuk-puppet'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(logRotator(numToKeepStr: '50')),
  ])

  try {
    stage("Checkout") {
      govuk.checkoutFromGitHubWithSSH(REPOSITORY)
    }

    stage("Bundle install") {
      govuk.bundleApp()
    }

    stage("puppet-librarian install") {
      govuk.runRakeTask('librarian:install')
    }

    stage("Spec tests") {
      govuk.runRakeTask('all_but_lint')
    }

    stage("Lint check") {
      govuk.runRakeTask('lint')
    }

    // Deploy on Integration (only master)
    if (env.BRANCH_NAME == 'master'){
      stage("Push release tag") {
        echo 'Pushing tag'
        govuk.pushTag(REPOSITORY, env.BRANCH_NAME, 'release_' + env.BUILD_NUMBER)
      }

      stage("Deploy on Integration") {
        build job: 'integration-puppet-deploy',
        parameters: [string(name: 'TAG', value: 'release_' + env.BUILD_NUMBER)]
      }
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }

  // Wipe the workspace
  deleteDir()
}
