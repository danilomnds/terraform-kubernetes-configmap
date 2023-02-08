resource "kubernetes_config_map" "config_map" {
  for_each = var.definition
  metadata {
    name      = lookup(each.value, "name", null) == null ? "container-azm-ms-agentconfig" : lookup(each.value, "name", null)
    namespace = lookup(each.value, "namespace", null) == null ? "kube-system" : lookup(each.value, "namespace", null)
  }
  data = merge(local.default_configmap_azr_monitor, lookup(each.value, "data", null))
}