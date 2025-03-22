pipeline {
    
    agent {
        label 'slave1'
        }
        
    tools {
        
        jdk 'openjdk-17'
        maven 'maven3'
    }    
    
    environment {
	
	SCANNER_HOME = tool 'sonar-scanner'
	VERSION = "${BUILD_ID}"
	
	
    }
   

    stages {
        
         stage('Clean WS') {
            steps {
                cleanWs()
            }
         }
        
        stage('Get SCM') {
            steps {
                echo 'Clone from GIT'
                git branch: 'releasebranch-1.0.0', url: 'https://github.com/prateeknegi2008/petclinic.git'
            }
        }
        
                stage('Mvn validate') {
            steps {
                sh 'mvn validate -Dmaven.skip.test=true'
                }
        }
        
        
         stage('Mvn compile') {
            steps {
                sh 'mvn compile -Dmaven.skip.test=true'
                }
        }
        
         stage('Mvn test') {
            steps {
                sh 'mvn test'
                }
        }
        
              stage('Trivyfs scan') {
            steps {
                echo 'Trivy fs scan'
                sh "mkdir trivy_report && trivy fs --format table -o trivy_report/trivy_fs_report_${VERSION}.html . "
            }
        }
        
          stage('Sonar-qube-scanner') {
            steps {
                withSonarQubeEnv('sonar-qube-server'){ 

                    sh ''' $SCANNER_HOME/bin/sonar-scanner  -Dsonar.projectName=pet-clinic2 -Dsonar.projectKey=pet-clinic2 -Dsonar.java.binaries=. -Dsonar.exclusions=trivy_report/**,petclinic-chart/** ''' 

                     

                } 
                }
        }
        

           stage('Sonar Quality gate1') {
            steps {
                timeout(time: 1, unit: 'HOURS')
                {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-qube-analysis3'
                }}
        }
        
        
                 stage('Mvn build') {
            steps {
                sh 'mvn clean package -Dmaven.skip.test=true'
                }
        }


                 stage('Move artifacts to nexus repo') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'spring-framework-petclinic', classifier: '', file: 'target/petclinic.war', type: 'war']], credentialsId: 'nexus-repo-cred', groupId: 'org.springframework.samples', nexusUrl: '192.168.1.171:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'war-repo', version: '5.3.13'
                }
        }
        
                stage('Buld docker image') {
            steps {
                sh '''
                docker build -t petclinic:v"$VERSION" .
                docker save petclinic:v${VERSION} | gzip > petclinicv${VERSION}.tar.gz
                
                '''
                
                }
        }
        
        stage('Trivy img scan') {
            steps {
                    timeout(time: 1, unit: 'HOURS')
                {
                sh " trivy image --format table -o trivy_report/trivy_img_report_${VERSION}.html petclinic:v${VERSION} --timeout 30m "
                }}
        }
    
    
        stage('Move Docker img to nexus repo') {
            steps {
                sh '''
                docker tag petclinic:v"$VERSION" 192.168.1.171:5001/nexus-repo/petclinic:v"$VERSION"
                docker login -u admin -p admin1234 192.168.1.171:5001
                docker push 192.168.1.171:5001/nexus-repo/petclinic:v"$VERSION"
                '''
                
                }}
                
            stage('Move helm chart to nexus repo') {
            steps {
                sh '''
                helm lint petclinic-chart
                helm template petclinic-chart
                sed -i "s/v15/v${VERSION}/" petclinic-chart/values.yaml
                sed -i "s/0.1.1/${VERSION}/" petclinic-chart/Chart.yaml 
                sed -i "s/1.0.0/${VERSION}/" petclinic-chart/Chart.yaml 
                helm package petclinic-chart
                curl -u admin:admin1234  http://192.168.1.171:8081/repository/helm-repo/ --upload-file petclinic-chart-"${VERSION}".tgz 
                '''
                
                }
        }
    
    

    
        
        
    }    
        
        

}

