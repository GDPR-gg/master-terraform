package vultr

import (
	"context"
	"errors"
	"fmt"

	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/vultr/govultr"
)

func dataSourceVultrApplication() *schema.Resource {
	return &schema.Resource{
		Read: dataSourceVultrApplicationRead,
		Schema: map[string]*schema.Schema{
			"filter": dataSourceFiltersSchema(),
			"deploy_name": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"name": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"short_name": {
				Type:     schema.TypeString,
				Computed: true,
			},
		},
	}
}

func dataSourceVultrApplicationRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*Client).govultrClient()

	filters, filtersOk := d.GetOk("filter")

	if !filtersOk {
		return fmt.Errorf("issue with filter: %v", filtersOk)
	}

	apps, err := client.Application.List(context.Background())

	if err != nil {
		return fmt.Errorf("Error getting applications: %v", err)
	}

	appList := []govultr.Application{}
	f := buildVultrDataSourceFilter(filters.(*schema.Set))

	for _, a := range apps {
		// we need convert the a struct INTO a map so we can easily manipulate the data here
		sm, err := structToMap(a)

		if err != nil {
			return err
		}

		if filterLoop(f, sm) {
			appList = append(appList, a)
		}
	}

	if len(appList) > 1 {
		return fmt.Errorf("your search returned too many results : %d. Please refine your search to be more specific", len(appList))
	}

	if len(appList) < 1 {
		return errors.New("no results were found")
	}

	d.SetId(appList[0].AppID)
	d.Set("deploy_name", appList[0].DeployName)
	d.Set("name", appList[0].Name)
	d.Set("short_name", appList[0].ShortName)
	return nil
}
