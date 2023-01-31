echo "Starting LEMP Stack"
echo "Setup Nginx PHP-FPM"
kubectl apply -f nginx-php/nginx-php-configmap.yaml
kubectl apply -f nginx-php/nginx-php-deployment.yaml
kubectl apply -f nginx-php/nginx-php-service.yaml
echo "Setup MariaDB"
kubectl apply -f mariadb/mariadb-pvc.yaml
kubectl apply -f mariadb/mariadb-deployment.yaml
kubectl apply -f mariadb/mariadb-service.yaml
echo "Sucsessfully started LEMP Stack"