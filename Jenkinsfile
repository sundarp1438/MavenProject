pipeline{
    agent { label 'rocky-linux-09' }
    tools{
        jdk 'JAVA_HOME'
        maven 'MAVEN_HOME'
    }
    environment {
        SCANNER_HOME=tool 'sonar-server'
	APP_NAME = "register-app-pipeline"
        RELEASE = "1.0.0"
        DOCKER_USER = "sundarp1985"
        DOCKER_PASS = 'docker'
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
	JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
    }
    stages {
        stage('Workspace Cleaning'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/sundarp1438/MavenProject.git'
            }
        }
      stage("Build Application"){
            steps {
                sh "mvn clean package"
            }

       }

       stage("Test Application"){
           steps {
                 sh "mvn test"
           }
       }
        stage("SonarQube Analysis"){
           steps {
	           script {
		        withSonarQubeEnv(credentialsId: 'sonar-token') { 
                        sh "mvn sonar:sonar"
		        }
	           }	
           }
       }
        stage("Quality Gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            } 
        }
        //stage('Jfrog Artifact Upload') {
         //   steps {
        //      rtUpload (
       //         serverId: 'artifactory',
       //         spec: '''{
       //               "files": [
       //                 {
       //                   "pattern": "*.war",
       //                    "target": "maven-snapshots"
       //                 }
       //             ]
      //          }'''
      //        )
     //     }
     //   }
        stage('OWASP DP SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'owasp-dp-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage('Build Docker Image') {
            steps {
                script{
                    sh 'docker build -t sundarp1985/maven-app-pipeline:latest .'
            }
        }
    }
      stage('Containerize And Test') {
            steps {
                script{
                    sh 'docker run -d --name maven-app sundarp1985/maven-app-pipeline:latest && sleep 10 && docker stop maven-app'
                }
            }
        }
       stage("Build & Push Docker Image") {
            steps {
                script {
                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image = docker.build "${IMAGE_NAME}"
                    }

                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
            }

       }
      
        stage("TRIVY Image Scan"){
            steps{
                sh "trivy image sundarp1985/maven-app-pipeline:latest > trivyimage.txt" 
            }
        }
      stage('post-build step') {
            steps {
		           sh '''
                echo "Successfull Pipeline"
		           '''
	    }
	}
    }
}
