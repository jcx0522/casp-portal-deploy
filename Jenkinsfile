pipeline {
  agent { label 'java' }
  stages {
    stage('build casp-portal product') {
      steps {
        withFolderProperties {
          withMaven(maven: 'M3', jdk: 'JDK8') {
            sh "sh build.sh casp-portal ${casp-portal_build_version}"
          }
        }
      }
    }
  }
}
