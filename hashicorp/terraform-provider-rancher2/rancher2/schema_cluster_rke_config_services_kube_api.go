package rancher2

import (
	"fmt"
	"reflect"

	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	auditv1 "k8s.io/apiserver/pkg/apis/audit/v1"
)

const (
	clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyApiversionTag = "apiVersion"
	clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyKindDefault   = "Policy"
	clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyKindTag       = "kind"
)

var (
	clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyRequired = []string{
		clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyApiversionTag,
		clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyKindTag}
)

//Schemas

func clusterRKEConfigServicesKubeAPIAuditLogConfigFields() map[string]*schema.Schema {
	s := map[string]*schema.Schema{
		"format": {
			Type:     schema.TypeString,
			Optional: true,
			Default:  "json",
		},
		"max_age": {
			Type:     schema.TypeInt,
			Optional: true,
			Default:  30,
		},
		"max_backup": {
			Type:     schema.TypeInt,
			Optional: true,
			Default:  10,
		},
		"max_size": {
			Type:     schema.TypeInt,
			Optional: true,
			Default:  100,
		},
		"path": {
			Type:     schema.TypeString,
			Optional: true,
			Default:  "/var/log/kube-audit/audit-log.json",
		},
		"policy": {
			Type:     schema.TypeString,
			Optional: true,
			Computed: true,
			ValidateFunc: func(val interface{}, key string) (warns []string, errs []error) {
				v, ok := val.(string)
				if !ok || len(v) == 0 {
					return
				}
				m, err := ghodssyamlToMapInterface(v)
				if err != nil {
					errs = append(errs, fmt.Errorf("%q must be in yaml format, error: %v", key, err))
					return
				}
				for _, k := range clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyRequired {
					check, ok := m[k].(string)
					if !ok || len(check) == 0 {
						errs = append(errs, fmt.Errorf("%s is required on yaml", k))
					}
					if k == clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyKindTag {
						if check != clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyKindDefault {
							errs = append(errs, fmt.Errorf("%s value %s should be: %s", k, check, clusterRKEConfigServicesKubeAPIAuditLogConfigPolicyKindDefault))
						}
					}

				}
				return
			},
			DiffSuppressFunc: func(k, old, new string, d *schema.ResourceData) bool {
				if old == "" || new == "" {
					return false
				}
				oldPolicy := &auditv1.Policy{}
				newPolicy := &auditv1.Policy{}
				oldMap, _ := ghodssyamlToMapInterface(old)
				newMap, _ := ghodssyamlToMapInterface(new)
				oldStr, _ := mapInterfaceToJSON(oldMap)
				newStr, _ := mapInterfaceToJSON(newMap)
				jsonToInterface(oldStr, oldPolicy)
				jsonToInterface(newStr, newPolicy)
				return reflect.DeepEqual(oldPolicy, newPolicy)
			},
		},
	}
	return s
}

func clusterRKEConfigServicesKubeAPIAuditLogFields() map[string]*schema.Schema {
	s := map[string]*schema.Schema{
		"configuration": {
			Type:     schema.TypeList,
			MaxItems: 1,
			Optional: true,
			Computed: true,
			Elem: &schema.Resource{
				Schema: clusterRKEConfigServicesKubeAPIAuditLogConfigFields(),
			},
		},
		"enabled": {
			Type:     schema.TypeBool,
			Optional: true,
			Default:  false,
		},
	}
	return s
}

func clusterRKEConfigServicesKubeAPIEventRateLimitFields() map[string]*schema.Schema {
	s := map[string]*schema.Schema{
		"configuration": {
			Type:     schema.TypeMap,
			Optional: true,
		},
		"enabled": {
			Type:     schema.TypeBool,
			Optional: true,
			Default:  false,
		},
	}
	return s
}

func clusterRKEConfigServicesKubeAPISecretsEncryptionConfigFields() map[string]*schema.Schema {
	s := map[string]*schema.Schema{
		"custom_config": {
			Type:     schema.TypeMap,
			Optional: true,
		},
		"enabled": {
			Type:     schema.TypeBool,
			Optional: true,
			Default:  false,
		},
	}
	return s
}

func clusterRKEConfigServicesKubeAPIFields() map[string]*schema.Schema {
	s := map[string]*schema.Schema{
		"admission_configuration": {
			Type:     schema.TypeMap,
			Optional: true,
		},
		"always_pull_images": {
			Type:     schema.TypeBool,
			Optional: true,
			Default:  false,
		},
		"audit_log": {
			Type:     schema.TypeList,
			MaxItems: 1,
			Optional: true,
			Elem: &schema.Resource{
				Schema: clusterRKEConfigServicesKubeAPIAuditLogFields(),
			},
		},
		"event_rate_limit": {
			Type:     schema.TypeList,
			MaxItems: 1,
			Optional: true,
			Elem: &schema.Resource{
				Schema: clusterRKEConfigServicesKubeAPIEventRateLimitFields(),
			},
		},
		"extra_args": {
			Type:     schema.TypeMap,
			Optional: true,
			Computed: true,
		},
		"extra_binds": {
			Type:     schema.TypeList,
			Optional: true,
			Elem: &schema.Schema{
				Type: schema.TypeString,
			},
		},
		"extra_env": {
			Type:     schema.TypeList,
			Optional: true,
			Elem: &schema.Schema{
				Type: schema.TypeString,
			},
		},
		"image": {
			Type:     schema.TypeString,
			Optional: true,
			Computed: true,
		},
		"pod_security_policy": {
			Type:     schema.TypeBool,
			Optional: true,
			Default:  false,
		},
		"secrets_encryption_config": {
			Type:     schema.TypeList,
			MaxItems: 1,
			Optional: true,
			Elem: &schema.Resource{
				Schema: clusterRKEConfigServicesKubeAPISecretsEncryptionConfigFields(),
			},
		},
		"service_cluster_ip_range": {
			Type:     schema.TypeString,
			Optional: true,
			Computed: true,
		},
		"service_node_port_range": {
			Type:     schema.TypeString,
			Optional: true,
			Computed: true,
		},
	}
	return s
}
