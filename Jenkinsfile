pipeline{
    agent { label 'rocky-linux-09' }
    tools{
        jdk 'JAVA_HOME'
        maven 'MAVEN_HOME'
    }
    environment {
        SCANNER_HOME=tool 'sonar-server'
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
        s stage('Push Image To Dockerhub') {
            steps {
                script{
                    withCredentials([string(credentialsId: 'DockerHubPass', variable: 'DockerHubPass')]) {
                    sh 'docker login -u sundarp1985 --password ${DockerHubPass}' }
                    sh 'docker push sundarp1985/maven-app-pipeline:latest'
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
