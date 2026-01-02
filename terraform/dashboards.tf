# Дашборды для кластера kubernetes
# =======================================================================
locals {
  dashboards = {
    keycloak : {
      title : "Keycloak Server"
      description : "Keycloak Server"
      parameters : [{
        id : "host_id",
        description : "Host",
        hidden : true,
        text : {
          default_value : "keycloak"
        }
        },
        {
          description : "folder id"
          hidden : true
          id : "folder_id"
          text : {
            default_value : var.YC_KEYS.folder_id
          }
      }]
      widgets : [{
        title : "Memory Usage"
        chart_id : "chart1id"
        targets : [{ query : "'sys.memory.MemFree'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}'}" },
        { query : "'sys.memory.MemTotal'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}'}" }]
        visualization_settings : { yaxis_settings : { left : { min : "0" } } }
        position : { h : 10, w : 15, x : 0, y : 0 }
        }, {
        title : "CPU Utilization"
        chart_id : "chart2id"
        targets : [{ query : "'cpu_utilization'{folderId = '{{folder_id}}', service = 'compute', resource_id = '{{host_id}}'}" }]
        visualization_settings : { yaxis_settings : { left : { min : "0" } } }
        position : { h : 10, w : 15, x : 0, y : 10 }
        }, {
        title : "Disk Usage"
        chart_id : "chart3id"
        targets : [{ query : "alias('sys.filesystem.SizeB'{folderId='{{folder_id}}', service='custom', host='{{host_id}}'}, 'Total')" },
        { query : "alias('sys.filesystem.UsedB'{folderId='{{folder_id}}', service='custom', host='{{host_id}}'}, 'Used')" }]
        visualization_settings : { yaxis_settings : { left : { min : "0" } } }
        position : { h : 10, w : 15, x : 15, y : 0 }
        }, {
        title : "Load average"
        chart_id : "chart4id"
        targets : [{ query : "alias('sys.proc.LoadAverage1min'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}'}, 'Load average 1min')" },
          { query : "alias('sys.proc.LoadAverage5min'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}'}, 'Load average 5min')" },
        { query : "alias('sys.proc.LoadAverage15min'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}'}, 'Load average 15min')" }]
        visualization_settings : { yaxis_settings : { left : { min : "0" } } }
        position : { h : 10, w : 15, x : 15, y : 10 }
        }, {
        title : "Disk utilization"
        chart_id : "chart5id"
        targets : [{ query : "alias('sys.io.Disks.ReadBytes'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}'}, 'Скорость чтения')" },
        { query : "alias('sys.io.Disks.WriteBytes'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}'}, 'Скорость записи')" }]
        visualization_settings : { yaxis_settings : { left : { min : "0" } } }
        position : { h : 10, w : 15, x : 0, y : 20 }
        }, {
        title : "Network utilization"
        chart_id : "chart6id"
        targets : [{ query : "alias('sys.net.Ifs.RxPackets'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}', intf = 'eth0'}, 'RxPackets')" },
        { query : "alias('sys.net.Ifs.TxPackets'{folderId = '{{folder_id}}', service = 'custom', host = '{{host_id}}', intf = 'eth0'}, 'TxPackets')" }]
        visualization_settings : { yaxis_settings : { left : { min : "0" } } }
        position : { h : 10, w : 15, x : 15, y : 20 }
      }]
    }
  }
}

resource "yandex_monitoring_dashboard" "dashboard" {
  for_each = local.dashboards

  name        = each.key
  title       = each.value.title
  description = each.value.description

  parametrization {
    dynamic "parameters" {
      for_each = lookup(each.value, "parameters", [])
      content {
        id          = parameters.value.id
        title       = lookup(parameters.value, "title", "")
        description = lookup(parameters.value, "description", "")
        hidden      = lookup(parameters.value, "hidden", false)
        dynamic "label_values" {
          for_each = flatten([lookup(parameters.value, "label_values", [])])
          content {
            label_key       = label_values.value.label_key
            default_values  = lookup(label_values.value, "default_values", ["*"])
            multiselectable = lookup(label_values.value, "multiselectable", false)
            selectors       = lookup(label_values.value, "selectors", "")
          }
        }
        dynamic "text" {
          for_each = flatten([lookup(parameters.value, "text", [])])
          content {
            default_value = text.value.default_value
          }
        }
      }
    }
  }

  dynamic "widgets" {
    for_each = lookup(each.value, "widgets", [])
    content {
      chart {
        title          = widgets.value.title
        chart_id       = widgets.value.chart_id
        display_legend = lookup(widgets.value, "display_legend", true)
        freeze         = lookup(widgets.value, "freeze", "FREEZE_DURATION_HOUR")
        queries {
          dynamic "target" {
            for_each = flatten([lookup(widgets.value, "targets", "")])
            content {
              query = target.value.query
            }
          }
        }
        visualization_settings {
          type        = lookup(widgets.value.visualization_settings, "type", "VISUALIZATION_TYPE_LINE")
          normalize   = lookup(widgets.value.visualization_settings, "normalize", false)
          show_labels = lookup(widgets.value.visualization_settings, "show_labels", true)
          title       = lookup(widgets.value.visualization_settings, "title", "visualization_settings title")
          yaxis_settings {
            dynamic "left" {
              for_each = flatten([lookup(widgets.value.visualization_settings.yaxis_settings, "left", [])])
              content {
                max         = lookup(left.value, "max", "")
                min         = lookup(left.value, "min", "")
                title       = lookup(left.value, "title", "")
                precision   = lookup(left.value, "precision", 3)
                type        = lookup(left.value, "type", "YAXIS_TYPE_LINEAR")
                unit_format = lookup(left.value, "unit_format", "UNIT_NONE")
              }
            }
          }
        }
      }
      position {
        h = widgets.value.position.h
        w = widgets.value.position.w
        x = widgets.value.position.x
        y = widgets.value.position.y
      }
    }
  }
}
