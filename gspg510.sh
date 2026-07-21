#!/bin/bash
clear
echo -e "\e[1;36m"
echo "  _    _ _____ __  __          _____  _    _ "
echo " | |  | |_   _|  \/  |   /\   |  __ \| |  | |"
echo " | |__| | | | | \  / |  /  \  | |__) | |  | |"
echo " |  __  | | | | |\/| | / /\ \ |  _  /| |  | |"
echo " | |  | |_| |_| |  | |/ ____ \| | \ \| |__| |"
echo " |_|  |_|_____|_|  |_/_/    \_\_|  \_\\____/ "
echo -e "\e[0m"
echo -e "\e[1;32mStarting GSP510 Setup by HIMARU...\e[0m\n"

read -p "CLUSTER_NAME (e.g. hello-world-3bn9): " CLUSTER_NAME
read -p "ZONE (e.g. europe-west4-a): " ZONE
read -p "NAMESPACE (e.g. gmp-srcf): " NAMESPACE
read -p "SERVICE_NAME (e.g. helloweb-service-11fj): " SERVICE_NAME

export PROJECT_ID=$(gcloud config get-value project)
export REGION="${ZONE%-*}"

echo -e "\n\e[1;33m[Task 1] Creating GKE cluster...\e[0m"
gcloud container clusters create $CLUSTER_NAME --zone=$ZONE --release-channel=regular --enable-autoscaling --num-nodes=3 --min-nodes=2 --max-nodes=6 --quiet
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

echo -e "\n\e[1;33m[Task 2] Managed Prometheus...\e[0m"
gcloud container clusters update $CLUSTER_NAME --zone=$ZONE --enable-managed-prometheus --quiet
kubectl create namespace $NAMESPACE

cat > prometheus-app.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-test
  labels: {app: prometheus-test}
spec:
  selector: {matchLabels: {app: prometheus-test}}
  replicas: 3
  template:
    metadata: {labels: {app: prometheus-test}}
    spec:
      nodeSelector: {kubernetes.io/os: linux, kubernetes.io/arch: amd64}
      containers:
        - image: nilebox/prometheus-example-app:latest
          name: prometheus-test
          ports: [{name: metrics, containerPort: 1234}]
          command: ["/main", "--process-metrics", "--go-metrics"]
EOF
kubectl -n $NAMESPACE apply -f prometheus-app.yaml

cat > pod-monitoring.yaml <<EOF
apiVersion: monitoring.googleapis.com/v1
kind: PodMonitoring
metadata:
  name: prometheus-test
  labels: {app.kubernetes.io/name: prometheus-test}
spec:
  selector: {matchLabels: {app: prometheus-test}}
  endpoints: [{port: metrics, interval: 60s}]
EOF
kubectl -n $NAMESPACE apply -f pod-monitoring.yaml

echo -e "\n\e[1;33m[Task 3] Deploy App...\e[0m"
gcloud storage cp -r gs://spls/gsp510/hello-app/ .
kubectl -n $NAMESPACE apply -f hello-app/manifests/helloweb-deployment.yaml

echo -e "\n\e[1;33m[Task 4] Metric & Alerting Policy (FIXED)...\e[0m"
gcloud logging metrics create pod-image-errors --description="Pod image errors" --log-filter="resource.type=\"k8s_pod\" severity=WARNING"
cat > alert.json <<EOF
{
  "displayName": "Pod Error Alert",
  "combiner": "OR",
  "conditions": [
    {
      "displayName": "Kubernetes Pod - logging/user/pod-image-errors",
      "conditionThreshold": {
        "filter": "metric.type=\"logging.googleapis.com/user/pod-image-errors\" AND resource.type=\"k8s_pod\"",
        "aggregations": [{"alignmentPeriod": "600s","crossSeriesReducer": "REDUCE_SUM","perSeriesAligner": "ALIGN_COUNT"}],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {"count": 1},
        "thresholdValue": 0
      }
    }
  ]
}
EOF
gcloud alpha monitoring policies create --policy-from-file=alert.json

echo -e "\n\e[1;33m[Task 5] Update App...\e[0m"
kubectl delete deployments helloweb -n $NAMESPACE
cat > hello-app/manifests/helloweb-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloweb
  labels: {app: hello}
spec:
  selector: {matchLabels: {app: hello, tier: web}}
  template:
    metadata: {labels: {app: hello, tier: web}}
    spec:
      containers:
      - name: hello-app
        image: us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
        ports: [{containerPort: 8080}]
        resources: {requests: {cpu: 200m}}
EOF
kubectl -n $NAMESPACE apply -f hello-app/manifests/helloweb-deployment.yaml

echo -e "\n\e[1;33m[Task 6] Dockerize & Push...\e[0m"
cat > hello-app/main.go <<EOF
package main
import ("fmt"; "log"; "net/http"; "os")
func main() {
    mux := http.NewServeMux()
    mux.HandleFunc("/", hello)
    port := os.Getenv("PORT"); if port == "" { port = "8080" }
    log.Printf("Server listening on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, mux))
}
func hello(w http.ResponseWriter, r *http.Request) {
    log.Printf("Serving request: %s", r.URL.Path)
    host, _ := os.Hostname()
    fmt.Fprintf(w, "Hello, world!\nVersion: 2.0.0\nHostname: %s\n", host)
}
EOF

gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
cd hello-app
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/hello-repo/hello-app:v2 .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/hello-repo/hello-app:v2

kubectl -n $NAMESPACE set image deployment/helloweb hello-app=$REGION-docker.pkg.dev/$PROJECT_ID/hello-repo/hello-app:v2
kubectl -n $NAMESPACE expose deployment helloweb --name=$SERVICE_NAME --type=LoadBalancer --port=8080 --target-port=8080

echo -e "\n\e[1;32mDONE! Menunggu External IP... (Tekan Ctrl+C jika IP sudah muncul)\e[0m"
kubectl -n $NAMESPACE get svc $SERVICE_NAME -w
