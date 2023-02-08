locals {
  default_configmap_azr_monitor = {
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
    "alertable-metrics-configuration-settings" = <<-EOT
                # Alertable metrics configuration settings for container resource utilization
                [alertable_metrics_configuration_settings.container_resource_utilization_thresholds]
                    # The threshold(Type Float) will be rounded off to 2 decimal points
                    # Threshold for container cpu, metric will be sent only when cpu utilization exceeds or becomes equal to the following percentage
                    container_cpu_threshold_percentage = 95.0
                    # Threshold for container memoryRss, metric will be sent only when memory rss exceeds or becomes equal to the following percentage
                    container_memory_rss_threshold_percentage = 95.0
                    # Threshold for container memoryWorkingSet, metric will be sent only when memory working set exceeds or becomes equal to the following percentage
                    container_memory_working_set_threshold_percentage = 95.0

                # Alertable metrics configuration settings for persistent volume utilization
                [alertable_metrics_configuration_settings.pv_utilization_thresholds]
                    # Threshold for persistent volume usage bytes, metric will be sent only when persistent volume utilization exceeds or becomes equal to the following percentage
                    pv_usage_threshold_percentage = 60.0

                # Alertable metrics configuration settings for completed jobs count
                [alertable_metrics_configuration_settings.job_completion_threshold]
                    # Threshold for completed job count , metric will be sent only for those jobs which were completed earlier than the following threshold
                    job_completion_threshold_time_minutes = 360
            EOT
    "config-version"                           = "ver1"
    "integrations"                             = <<-EOT
                [integrations.azure_network_policy_manager]
                    collect_basic_metrics = false
                    collect_advanced_metrics = false
                [integrations.azure_subnet_ip_usage]
                    enabled = false
            EOT
    "log-data-collection-settings"             = <<-EOT
                # Log data collection settings
                # Any errors related to config map settings can be found in the KubeMonAgentEvents table in the Log Analytics workspace that the cluster is sending data to.

                [log_collection_settings]
                   [log_collection_settings.stdout]
                      # In the absense of this configmap, default value for enabled is true
                      enabled = false
                      # exclude_namespaces setting holds good only if enabled is set to true
                      # kube-system log collection is disabled by default in the absence of 'log_collection_settings.stdout' setting. If you want to enable kube-system, remove it from the following setting.
                      # If you want to continue to disable kube-system log collection keep this namespace in the following setting and add any other namespace you want to disable log collection to the array.
                      # In the absense of this configmap, default value for exclude_namespaces = ["kube-system"]
                      exclude_namespaces = ["kube-system"]

                   [log_collection_settings.stderr]
                      # Default value for enabled is true
                      enabled = false
                      # exclude_namespaces setting holds good only if enabled is set to true
                      # kube-system log collection is disabled by default in the absence of 'log_collection_settings.stderr' setting. If you want to enable kube-system, remove it from the following setting.
                      # If you want to continue to disable kube-system log collection keep this namespace in the following setting and add any other namespace you want to disable log collection to the array.
                      # In the absense of this cofigmap, default value for exclude_namespaces = ["kube-system"]
                      exclude_namespaces = ["kube-system"]

                   [log_collection_settings.env_var]
                      # In the absense of this configmap, default value for enabled is true
                      enabled = true
                   [log_collection_settings.enrich_container_logs]
                      # In the absense of this configmap, default value for enrich_container_logs is false
                      enabled = false
                      # When this is enabled (enabled = true), every container log entry (both stdout & stderr) will be enriched with container Name & container Image
                   [log_collection_settings.collect_all_kube_events]
                      # In the absense of this configmap, default value for collect_all_kube_events is false
                      # When the setting is set to false, only the kube events with !normal event type will be collected
                      enabled = false
                      # When this is enabled (enabled = true), all kube events including normal events will be collected
                   #[log_collection_settings.schema]
                      # In the absence of this configmap, default value for containerlog_schema_version is "v1"
                      # Supported values for this setting are "v1","v2"
                      # See documentation at https://aka.ms/ContainerLogv2 for benefits of v2 schema over v1 schema before opting for "v2" schema
                      # containerlog_schema_version = "v2"
            EOT
    "metric_collection_settings"               = <<-EOT
                # Metrics collection settings for metrics sent to Log Analytics and MDM
                [metric_collection_settings.collect_kube_system_pv_metrics]
                  # In the absense of this configmap, default value for collect_kube_system_pv_metrics is false
                  # When the setting is set to false, only the persistent volume metrics outside the kube-system namespace will be collected
                  enabled = false
                  # When this is enabled (enabled = true), persistent volume metrics including those in the kube-system namespace will be collected
            EOT
    "prometheus-data-collection-settings"      = <<-EOT
                # Custom Prometheus metrics data collection settings
                [prometheus_data_collection_settings.cluster]
                    # Cluster level scrape endpoint(s). These metrics will be scraped from agent's Replicaset (singleton)
                    # Any errors related to prometheus scraping can be found in the KubeMonAgentEvents table in the Log Analytics workspace that the cluster is sending data to.

                    #Interval specifying how often to scrape for metrics. This is duration of time and can be specified for supporting settings by combining an integer value and time unit as a string value. Valid time units are ns, us (or µs), ms, s, m, h.
                    interval = "1m"

                    ## Uncomment the following settings with valid string arrays for prometheus scraping
                    #fieldpass = ["metric_to_pass1", "metric_to_pass12"]

                    #fielddrop = ["metric_to_drop"]

                    # An array of urls to scrape metrics from.
                    # urls = ["http://myurl:9101/metrics"]

                    # An array of Kubernetes services to scrape metrics from.
                    # kubernetes_services = ["http://my-service-dns.my-namespace:9102/metrics"]

                    # When monitor_kubernetes_pods = true, replicaset will scrape Kubernetes pods for the following prometheus annotations:
                    # - prometheus.io/scrape: Enable scraping for this pod
                    # - prometheus.io/scheme: If the metrics endpoint is secured then you will need to
                    #     set this to `https` & most likely set the tls config.
                    # - prometheus.io/path: If the metrics path is not /metrics, define it with this annotation.
                    # - prometheus.io/port: If port is not 9102 use this annotation
                    monitor_kubernetes_pods = false

                    ## Restricts Kubernetes monitoring to namespaces for pods that have annotations set and are scraped using the monitor_kubernetes_pods setting.
                    ## This will take effect when monitor_kubernetes_pods is set to true
                    ##   ex: monitor_kubernetes_pods_namespaces = ["default1", "default2", "default3"]
                    # monitor_kubernetes_pods_namespaces = ["default1"]

                    ## Label selector to target pods which have the specified label
                    ## This will take effect when monitor_kubernetes_pods is set to true
                    ## Reference the docs at https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
                    # kubernetes_label_selector = "env=dev,app=nginx"

                    ## Field selector to target pods which have the specified field
                    ## This will take effect when monitor_kubernetes_pods is set to true
                    ## Reference the docs at https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/
                    ## eg. To scrape pods on a specific node
                    # kubernetes_field_selector = "spec.nodeName=$HOSTNAME"

                [prometheus_data_collection_settings.node]
                    # Node level scrape endpoint(s). These metrics will be scraped from agent's DaemonSet running in every node in the cluster
                    # Any errors related to prometheus scraping can be found in the KubeMonAgentEvents table in the Log Analytics workspace that the cluster is sending data to.

                    #Interval specifying how often to scrape for metrics. This is duration of time and can be specified for supporting settings by combining an integer value and time unit as a string value. Valid time units are ns, us (or µs), ms, s, m, h.
                    interval = "1m"

                    ## Uncomment the following settings with valid string arrays for prometheus scraping

                    # An array of urls to scrape metrics from. $NODE_IP (all upper case) will substitute of running Node's IP address
                    # urls = ["http://$NODE_IP:9103/metrics"]

                    #fieldpass = ["metric_to_pass1", "metric_to_pass12"]

                    #fielddrop = ["metric_to_drop"]
            EOT
    "schema-version"                           = "v1"
  }
}