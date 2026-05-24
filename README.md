# TP 10 — Kubernetes avanzado: Helm + Ingress

## Estructura del Chart

devops-portfolio/ 
├── Chart.yaml # metadata del chart 
├── values.yaml # valores por defecto 
├── values-dev.yaml # override para desarrollo 
├── values-prod.yaml # override para producción 
└── templates/ 
├── _helpers.tpl # funciones reutilizables 
├── namespace.yaml 
├── secret.yaml 
├── configmap.yaml 
├── postgres.yaml # PVC + Deployment + Service 
├── backend.yaml # Deployment + HPA + Service 
├── frontend.yaml # Deployment + Service 
├── ingress.yaml # Ingress con rutas 
└── NOTES.txt # mensaje post-instalación

## Comandos principales

Ejecutar en bash
# Validar el chart
helm lint devops-portfolio/

# Ver manifests generados
helm template mi-app devops-portfolio/ --values values-dev.yaml

# Instalar
helm install mi-app devops-portfolio/ --values values-dev.yaml

# Actualizar
helm upgrade mi-app devops-portfolio/ --values values-dev.yaml

# Rollback
helm rollback mi-app 1

# Desinstalar
helm uninstall mi-app
Ingress: routing por paths
Path	Servicio destino
/	frontend-service :80
/api/*	backend-service :5000
/health	backend-service :5000
Multi-entorno
helm install mi-app devops-portfolio/ --values values-dev.yaml   # dev
helm install mi-app devops-portfolio/ --values values-prod.yaml  # prod
