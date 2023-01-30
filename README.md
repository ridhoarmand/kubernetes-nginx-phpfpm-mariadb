# Kubernetes Nginx PHP-FPM

This is a simple example of how to deploy a PHP application using Nginx and PHP-FPM.

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
          image: php:fpm
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
    phpinfo();
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

## Results:

![Alt Text](https://i.imgur.com/YzsekAu.png)
![Alt Text](https://i.imgur.com/YXngk7G.png)
