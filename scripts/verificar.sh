#!/bin/bash

set -uo pipefail
NS="devops-portfolio"
ERRORS=0
ok()   { echo "  [OK]   $1"; }
fail() { echo "  [FAIL] $1"; ERRORS=$((ERRORS+1)); }

echo "=== Verificación Helm + Ingress — TP 10 ==="
echo ""
echo "--- Helm release ---"
STATUS=$(helm status mi-app -n $NS 2>/dev/null \
| grep "^STATUS:" \
| awk '{print $2}')

if [ "$STATUS" = "deployed" ]; then
    ok "Release mi-app  ^f^r $STATUS"
else
    fail "Release mi-app no encontrado"
fi

echo ""
echo "--- Pods ---"
kubectl get pods -n $NS --no-headers 2>/dev/null | while read line; do
    NAME=$(echo $line   | awk '{print $1}')
    STATUS=$(echo $line | awk '{print $3}')
    READY=$(echo $line  | awk '{print $2}')
    [ "$STATUS" = "Running" ] && ok "$NAME  ^f^r $STATUS ($READY)" || fail "$NAME  ^f^r $STATUS"
done

echo ""
echo "--- Ingress ---"
kubectl get ingress -n $NS --no-headers 2>/dev/null | while read line; do
    NAME=$(echo $line | awk '{print $1}')
    HOST=$(echo $line | awk '{print $3}')
    ok "$NAME  ^f^r host: $HOST"
done

echo ""
echo "--- Healthcheck via Ingress ---"

NODE_IP=$(kubectl get nodes \
  -o jsonpath='{.items[0].status.addresses[0].address}' 2>/dev/null)

INGRESS_PORT=$(kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

for path in "/" "/health" "/api/notes"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Host: devops-portfolio.dev" \
      --max-time 5 \
      "http://$NODE_IP:$INGRESS_PORT$path" 2>/dev/null || echo "000")

    [ "$CODE" = "200" ] \
      && ok "$path  ^f^r HTTP $CODE" \
      || fail "$path  ^f^r HTTP $CODE"
done

echo ""
[ "$ERRORS" -eq 0 ] && echo "TP 10 OK" || echo "$ERRORS checks fallaron"
