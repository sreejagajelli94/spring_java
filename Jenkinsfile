pipeline {
    agent any
    environment {
        MAVEN_HOME = tool 'm3'
        SONAR_TOKEN='e396e9a901ac1d30b4977ac89b08801a68897dfa'
        APP_HOME='/home/app'
        PRAGRA_BATCH='devs'
        DOCKERHUB_CREDENTIALS = credentials('sreejagajelli-dockerhub')
    }
    options { 
        quietPeriod(30) 
    }
    parameters { 
            choice(name: 'ENV_TO_DEPLOY', 
            choices: ['ST', 'UAT', 'STAGING'], description: 'Select a Env to deploy') 

             booleanParam(name: 'RUN', defaultValue: true, description: 'SELECT TO RUN')
    }
    triggers {
        pollSCM('* * * * *')
    }
    tools{
        maven  'm3'
        jdk 'jdk11'
    }

    stages {
        stage('Clean Ws') {
            steps{
                cleanWs()
            }
        }
        stage('Git CheckoutOut'){
            steps{
                checkout scm
            }
        }
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }
       stage('Static Code Analaysis') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonartoken', installationName: 'sonarcloud') {
                    sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
                }
            }
        }
         stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

         stage('Package') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker  build -t sreejagajelli/httpd_apache:latest .'
            }
        }
        stage('Docker Login'){
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('Docker Image Push') {
            steps {
                sh 'docker push sreejagajelli/httpd_apache:latest'
            }
        }
        stage ('Publish to Artifactory') {
            steps {
                rtUpload (
                    serverId: 'artifactory1',
                    spec: '''{
                        "files": [
                            {
                            "pattern": "*dummy*.jar",
                            "target": "libs-release-local/dummy/"
                            },
                            {
                            "pattern": "pom.xml",
                            "target": "libs-release-local/dummy/"
                            }
                        ]
                    }''',
                    // Optional - Associate the uploaded files with the following custom build name and build number,
                    // as build artifacts.
                    // If not set, the files will be associated with the default build name and build number (i.e the
                    // the Jenkins job name and number).
                    buildName: 'holyFrog',
                    buildNumber: '42',
                    // Optional - Only if this build is associated with a project in Artifactory, set the project key as follows.
                    project: 'my-project-key'
 
                )

            }
        }
    }

    post {
        always {
            echo 'ALL GOOD '
            sh 'docker logout'
        }
    }


}
