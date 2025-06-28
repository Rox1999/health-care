pipeline {
    agent any

    environment {
        IMAGE_NAME = "rox1999/star-agile-health-care"
        TEST_SERVER = "13.233.198.245"
        PROD_SERVER = "35.154.164.60"
        NODE_PORT = "30080"  // Example port for NodePort, change as needed
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Rox1999/health-care.git', branch: 'master'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $IMAGE_NAME:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy Cluster to Test Server') {
            steps {
                sshagent(['root-server-key']) {
                    sh """
                        ssh root@$TEST_SERVER 'kubectl delete pod healthcare-app --ignore-not-found=true'
                        ssh root@$TEST_SERVER 'cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: Pod
metadata:
  name: healthcare-app
spec:
  containers:
  - name: healthcare
    image: $IMAGE_NAME:latest
    ports:
    - containerPort: 8080
EOF'

                        ssh root@$TEST_SERVER 'cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: Service
metadata:
  name: healthcare-service
spec:
  type: NodePort
  selector:
    app: healthcare-app
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort: $NODE_PORT
EOF'
                    """
                }
            }
        }

        stage('Approval for Deploying to Prod') {
            steps {
                input message: 'Proceed to Production Deployment?'
            }
        }

        stage('Deploy Cluster to Prod Server') {
            steps {
                sshagent(['root-server-key']) {
                    sh """
                        ssh root@$PROD_SERVER 'docker pull $IMAGE_NAME:latest'
                        ssh root@$PROD_SERVER 'kubectl delete pod healthcare-app --ignore-not-found=true'
                        ssh root@$PROD_SERVER 'cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: Pod
metadata:
  name: healthcare-app
spec:
  containers:
  - name: healthcare
    image: $IMAGE_NAME:latest
    ports:
    - containerPort: 8080
EOF'

                        ssh root@$PROD_SERVER 'cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: Service
metadata:
  name: healthcare-service
spec:
  type: NodePort
  selector:
    app: healthcare-app
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort: $NODE_PORT
EOF'
                    """
                }
            }
        }
    }
}
