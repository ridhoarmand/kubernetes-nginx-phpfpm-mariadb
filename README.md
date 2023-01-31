# Kubernetes Nginx PHP-FPM

This is a simple example of how to deploy a PHP application using Nginx, PHP-FPM and MariaDB.

Just run the shell script to deploy the application.

```
sh run.sh
```

#### run.sh

```
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
```

#### nginx-php-deployment.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/conf.d
            - name: webapp
              mountPath: /var/www/html
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config
        - name: webapp
          configMap:
            name: webapp
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpfpm-deployment
spec:
  selector:
    matchLabels:
      app: phpfpm
  replicas: 1
  template:
    metadata:
      labels:
        app: phpfpm
    spec:
      containers:
        - name: phpfpm
          image: ridhoarmand/php:8.2-fpm
          ports:
            - containerPort: 9000
          volumeMounts:
            - name: webapp
              mountPath: /var/www/html
      volumes:
        - name: webapp
          configMap:
            name: webapp
```

#### nginx-php-configmap.yaml

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  default.conf: |
    server {
        listen 80;
        listen [::]:80;
        access_log off;
        root /var/www/html;
        index index.php;
        server_name localhost;
        server_tokens off;
        location / {
            # First attempt to serve request as file, then
            # as directory, then fall back to displaying a 404.
            try_files $uri $uri/ /index.php?$args;
        }
        # pass the PHP scripts to FastCGI server listening on phpfpm-service:9000
            location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass phpfpm-service:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param SCRIPT_NAME $fastcgi_script_name;
        }
      }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp
data:
  index.php: |
    <?php
      echo "Hello World";
    ?>
  info.php: |
    <?php
      phpinfo();
    ?>
  koneksi.php: |
    <?php
      $servername = "mariadb-service";
      $username = "myuser";
      $password = "mypassword";
      $dbname = "mydb";
      // Create connection
      $conn = mysqli_connect($servername, $username, $password, $dbname);
      // Check connection
      if (!$conn) {
        die("Connection failed: " . mysqli_connect_error());
      }
      echo "Connected successfully";
    ?>
```

#### nginx-php-service.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  selector:
    app: nginx
  ports:
    - name: http
      port: 80
      targetPort: 80
      nodePort: 30080
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: phpfpm-service
  labels:
    app: phpfpm
spec:
  selector:
    app: phpfpm
  ports:
    - name: phpfpm
      port: 9000
      targetPort: 9000
  type: ClusterIP
```

#### mariadb-pvc.yaml

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

#### mariadb-deployment.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb-deployment
spec:
  selector:
    matchLabels:
      app: mariadb
  replicas: 1
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
        - name: mariadb
          image: mariadb:latest
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: rootpassword
            - name: MYSQL_DATABASE
              value: mydb
            - name: MYSQL_USER
              value: myuser
            - name: MYSQL_PASSWORD
              value: mypassword
          volumeMounts:
            - name: mariadb-data
              mountPath: /var/lib/mysql
      volumes:
        - name: mariadb-data
          persistentVolumeClaim:
            claimName: mariadb-data-pvc
```

#### mariadb-service.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: mariadb-service
  labels:
    app: mariadb
spec:
  selector:
    app: mariadb
  ports:
    - name: mariadb
      port: 3306
      targetPort: 3306
  type: ClusterIP
```

#### PHP Container Dockerfile

```
FROM php:fpm
RUN  docker-php-ext-install pdo_mysql mysqli
```

## Results:

![Alt Text](https://i.imgur.com/Qi79eyz.png)

![Alt Text](https://i.imgur.com/Tlj1aVv.png)

![Alt Text](https://i.imgur.com/1HobEHZ.png)

![Alt Text](https://i.imgur.com/Rg3U0t6.png)
