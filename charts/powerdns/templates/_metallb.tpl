{{- define "metallb.pool.annotation" -}}
{{ printf "metallb.universe.tf/address-pool: %s" .Values.metallb.address_pool }}
{{- end -}}
