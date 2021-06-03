try{
    node{
        def mvnHome = tool name: 'MyMaven', type: 'maven'
        def myDockerImage
        def myWorkspace = pwd()
        
        stage('Code Checkout'){
            echo "Checking out the code from Github repository..."
            git branch: 'master' , url: 'https://github.com/vibhawa/batch10.git'
        }
        stage('Build, Test and Package the code'){
            echo "Packaging the code..."
            sh "${mvnHome}/bin/mvn clean surefire-report:report package"
        }
        stage('Analyze with SonarCloud'){
            echo "Analyzing the project with SonarCloud..."
            withCredentials([string(credentialsId: 'CaseStudySonar', variable: 'SonarCredentials')]) {
               sh "${mvnHome}/bin/mvn sonar:sonar -Dsonar.projectKey=CaseStudy -Dsonar.organization=devops-bootcamp -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=${SonarCredentials}"
            }
        }
        stage('AppScan with HCL AppScan'){
            echo "Scanning app with HCL AppScan..."
            appscan application: 'ede2a9b3-3435-4657-b564-1b1d36622525', credentials: '758804bd-4faa-433a-bd48-146549fea755',  name: 'CaseStudy', scanner: static_analyzer(hasOptions: false, target: "${myWorkspace}/target/bootcamp-0.0.1-SNAPSHOT.jar"), type: 'Static Analyzer'
        }
        stage('Publish HTML Reports'){
            echo "Publishing HTML reports for JUnit tests..."
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: false, reportDir: 'target/site', reportFiles: 'surefire-report.html', reportName: 'HTML Report', reportTitles: ''])
        }
        stage('Build Docker Image'){
            echo "Building Docker image for our application..."
            script{
                myDockerImage = docker.build 'diablonemesis/casestudy:1.0'
            }
        }
        stage('Aurhenticate to Docker Hub and push Docker Image'){
            echo "Pushing the image to Docker Hub"
            withCredentials([usernameColonPassword(credentialsId: 'DockerHub', variable: 'DockerHub')]) {
                script { 
                    docker.withRegistry( 'https://registry.hub.docker.com/', 'DockerHub' ) { 
                        myDockerImage.push() 
                        }
                    } 
            }
                       
        }
        stage('Deploy applicaion to Slave Node'){
            echo "Deploying the build to the target Slave node..."
            ansiblePlaybook become: true, credentialsId: 'AnsibleKey', disableHostKeyChecking: true, installation: 'MyAnsible', inventory: '/etc/ansible/hosts', playbook: 'playbook.yml'
        }
        currentBuild.result = "SUCCESS"   
    }
}
catch(Exception err){
         currentBuild.result = "FAILURE"         
}
finally {
        stage("Send Notification for build: ${currentBuild.result}"){
            if(currentBuild.result == "FAILURE" ){
                emailext attachLog: true, body: 'Your build failed, please login to the Jenkins and check your Build Pipeline logs.', subject: 'Build Status for ${JOB_NAME} - ${BUILD_NUMBER}', to: 'bajpai.bajpai04@gmail.com,'
            }
            else
            {
                emailext attachLog: true, body: 'Your build was successful!!!', subject: 'Build Status for ${JOB_NAME} - ${BUILD_NUMBER}', to: 'bajpai.bajpai04@gmail.com,'
            }
        }
    }