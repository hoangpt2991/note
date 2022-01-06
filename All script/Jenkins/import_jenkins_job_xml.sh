#Jenkins Thinbackup plugin: backup and restore jenkins jobs
# default: /var/lib/jenkins/backups/
# download jenkins-cli.jar on Jenkins managerment

jenkins_url=http://localhost:8080/jenkins
for i in $(cat name_jobs.txt);
do
	echo This line $i
#	 curl -k -X POST 'http://admin:114631f13af9fa64ae3b562b43ae2aa897@localhost:8080/jenkins/createItem?name=$i' --header "Content-Type: application/xml" -d jobs/$i/config.xml
#   java -jar jenkins-cli.jar -s $jenkins_url  create-job ${i} < jobs/$i/config.xml
java -jar jenkins-cli.jar -s $jenkins_url -auth <user>:<token>  create-job $i < $i/config.xml

done



#Pass command: java -jar jenkins-cli.jar -s http://192.168.1.201:8080/ -auth <user>:<token>  create-job AIG-SIT-B2B-FULLTEST < jobs/AIG-SIT-B2B-FULLTEST/config.xml
