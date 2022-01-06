#!groovy?
pipeline {

		agent any

    parameters {
        string(name: 'Project_name', defaultValue: "MISR", description: '')
        string(name: 'Working_branch', defaultValue: "MLI_ILPRD", description: '')
        string(name: 'Target_project_name', defaultValue: "bpham26", description: '')
        password(name: 'creden', defaultValue: "bpham26:37c8336f838def04c8a6bc5afd8b2a46b98985f4@",description: 'Encryption key')
        text(name: 'List_repositories', 
                 defaultValue: '''integral-Life
integral-smart
integral-bundle
                ''',
                 description: 'list of reposistory to affect the action')

    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '10'))
        disableConcurrentBuilds()
    }

	stages {
	    stage('Remove old file') {
		    steps {
		        echo "Clear space"
		        sh '''
		        cd ${WORKSPACE}/
		        rm -rf *
		        '''
		    }
		}
        
        stage('Stage 0: set build version') { 
			steps {
wrap([$class: "MaskPasswordsBuildWrapper",
              varPasswordPairs: [[password: creden],
                                 [password: creden]]]) {
          echo "Password: ${creden}"
          echo "Secret: ${creden}"
        }
				echo "Stage: Start Pipeline"
				    script {
                    def VERSION = VersionNumber projectStartDate: '2019-01-01', versionNumberString: '${BUILD_YEAR}.${BUILD_MONTH,XX}.${BUILD_DAY,XX}.${BUILD_NUMBER}', versionPrefix: ''
                    env.DPLVERSION="${VERSION}"
                    echo "${VERSION}"
                    currentBuild.displayName = "${DPLVERSION}"
                    echo "Show all attribute we are working with"
                    echo "${Project_name}"
                    echo "${Working_branch}"
                    echo "${Target_project_name}"

				}
			}
		}
        stage('Stage git clone list reposistories') { 
			steps {
			 wrap([$class: 'MaskPasswordsBuildWrapper', varPasswordPairs: [[password: creden]]]) {      
				script {
				    echo "Start to clone and conduct subtasks"          
                    sh '''
                    for repo in ${List_repositories}
                    do
                        cd ${WORKSPACE}
                        git clone -b ${Working_branch} https://${creden}github.dxc.com/${Project_name}/${repo}.git ${Project_name}-${repo} && cd ${Project_name}-${repo}
                        git remote add misr https://${creden}github.dxc.com/${Target_project_name}/${repo}.git
                        git push misr ${Working_branch}:${Working_branch}
                    done
                    '''	
                    }}
			
			

	            }
        }

       

	}
	post {

	always {
			cleanWs()
	}
  }
}


================================================
        stage('Time out') {
            steps {
                timeout(time: 350, unit: 'SECONDS') {

                sh '''
                whoami
                rsync -avu --delete "/tmp/source/" "/var/www/html/target/"
                
                '''
                }
            }
        }
================================================		
		withCredentials([string(credentialsId: 'my-pass', variable: 'PW1')]) {
    echo "My password is '${PW1}'!"
}