# Module - Configmap K8S
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module created to help the creation of configmaps. It's initially preconfigured to create a configmap for the Azure Monitor, you can check the default values on [locals.tf](locals.tf). It basically disables the stdout/stderr because of the costing.

It can be used in GKE, OKE or EKS without any customization. 

If you want to define your own default configmap, you'll have to edit the [locals.tf](locals.tf).

## Compatibility matrix

| Module Version | Terraform Version | Kubernetes Provider Version |
|----------------|-------------------| --------------------------- |
| v1.0.0         | v1.3.6            | 2.17.0                      |

## Specifying a version

To avoid that your code get automatically updates for the module is mandatory to set the version using the `source` option. 
By defining the `?ref=***` in the the URL, you can use a specific version of the module.

Note: The `?ref=***` refers a tag on the git module repo.

## Use case for default azure monitor configmap

```hcl
module "<clustername>-<configmap-name>" {
  source = "git::https://github.com/danilomnds/terraform-kubernetes-configmap?ref=v1.0.0"
  definition = {
    configmap-azr-monitor = {
    }
  }
}
```

## Use case for custom configmap

```hcl
module "<clustername>-<configmap-name>" {
  source = "git::https://github.com/danilomnds/terraform-kubernetes-configmap?ref=v1.0.0"
  definition = {
    <your-configmap-name> = {
      # Default kube-system
      namespace = <namespace-name>
      # if you want create the configmap with a custom name. Default container-azm-ms-agentconfig
      name = "custom"    
      # here you can the the key/value for your configmap. Ex:
      data = {
            "agent-settings"                           = <<-EOT
                # prometheus scrape fluent bit settings for high scale
                # buffer size should be greater than or equal to chunk size else we set it to chunk size.
                [agent_settings.prometheus_fbit_settings]
                  tcp_listener_chunk_size = 10
                  tcp_listener_buffer_size = 10
                  tcp_listener_mem_buf_limit = 200

                # The following settings are "undocumented", we don't recommend uncommenting them unless directed by Microsoft.
                # They increase the maximum stdout/stderr log collection rate but will also cause higher cpu/memory usage.
                # [agent_settings.fbit_config]
                #   log_flush_interval_secs = "1"                 # default value is 15
                #   tail_mem_buf_limit_megabytes = "10"           # default value is 10
                #   tail_buf_chunksize_megabytes = "1"            # default value is 32kb (comment out this line for default)
                #   tail_buf_maxsize_megabytes = "1"              # defautl value is 32kb (comment out this line for default)
            EOT    
      }
    }
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| definition | Definitions for the configmap creation  | `any` | n/a | `Yes` |

## Documentation

Terraform kubernetes_config_map: <br>
[https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)<br>