/* Copyright © 2019 VMware, Inc. All Rights Reserved.
   SPDX-License-Identifier: MPL-2.0 */

package nsxt

import (
	"fmt"
	"github.com/google/uuid"
	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/terraform"
	gm_infra "github.com/vmware/vsphere-automation-sdk-go/services/nsxt-gm/global_infra"
	gm_model "github.com/vmware/vsphere-automation-sdk-go/services/nsxt-gm/model"
	"github.com/vmware/vsphere-automation-sdk-go/services/nsxt/infra"
	"github.com/vmware/vsphere-automation-sdk-go/services/nsxt/model"
	"testing"
)

func TestAccDataSourceNsxtPolicyTier0Gateway_basic(t *testing.T) {
	name := "terraform_test"
	testResourceName := "data.nsxt_policy_tier0_gateway.test"

	resource.Test(t, resource.TestCase{
		PreCheck:  func() { testAccPreCheck(t) },
		Providers: testAccProviders,
		CheckDestroy: func(state *terraform.State) error {
			return testAccDataSourceNsxtPolicyTier0GatewayDeleteByName(name)
		},
		Steps: []resource.TestStep{
			{
				PreConfig: func() {
					if err := testAccDataSourceNsxtPolicyTier0GatewayCreate(name); err != nil {
						panic(err)
					}
				},
				Config: testAccNsxtPolicyTier0GatewayReadTemplate(name),
				Check: resource.ComposeTestCheckFunc(
					resource.TestCheckResourceAttr(testResourceName, "display_name", name),
					resource.TestCheckResourceAttr(testResourceName, "description", name),
					resource.TestCheckResourceAttrSet(testResourceName, "path"),
				),
			},
			{
				Config: testAccNsxtPolicyEmptyTemplate(),
			},
		},
	})
}

func testAccDataSourceNsxtPolicyTier0GatewayCreate(name string) error {
	connector, err := testAccGetPolicyConnector()
	if err != nil {
		return fmt.Errorf("Error during test client initialization: %v", err)
	}

	displayName := name
	description := name
	obj := model.Tier0{
		Description: &description,
		DisplayName: &displayName,
	}

	// Generate a random ID for the resource
	uuid, _ := uuid.NewRandom()
	id := uuid.String()

	if testAccIsGlobalManager() {
		gmObj, err := convertModelBindingType(obj, model.Tier0BindingType(), gm_model.Tier0BindingType())
		if err != nil {
			return err
		}

		client := gm_infra.NewDefaultTier0sClient(connector)
		err = client.Patch(id, gmObj.(gm_model.Tier0))

	} else {
		client := infra.NewDefaultTier0sClient(connector)
		err = client.Patch(id, obj)
	}
	if err != nil {
		return fmt.Errorf("Error during Tier0 creation: %v", err)
	}
	return nil
}

func testAccDataSourceNsxtPolicyTier0GatewayDeleteByName(name string) error {
	connector, err := testAccGetPolicyConnector()
	if err != nil {
		return fmt.Errorf("Error during test client initialization: %v", err)
	}

	// Find the object by name
	if testAccIsGlobalManager() {
		objID, err := testGetObjIDByName(name, "Tier0")
		if err == nil {
			client := gm_infra.NewDefaultTier0sClient(connector)
			err := client.Delete(objID)
			if err != nil {
				return handleDeleteError("Tier0", objID, err)
			}
			return nil
		}
	} else {
		client := infra.NewDefaultTier0sClient(connector)
		objList, err := client.List(nil, nil, nil, nil, nil, nil)
		if err != nil {
			return fmt.Errorf("Error while reading Tier0s: %v", err)
		}
		for _, objInList := range objList.Results {
			if *objInList.DisplayName == name {
				err := client.Delete(*objInList.Id)
				if err != nil {
					return fmt.Errorf("Error during Tier0 deletion: %v", err)
				}
				return nil
			}
		}
	}
	return fmt.Errorf("Error while deleting Tier0 '%s': resource not found", name)
}

func testAccNsxtPolicyTier0GatewayReadTemplate(name string) string {
	return fmt.Sprintf(`
data "nsxt_policy_tier0_gateway" "test" {
  display_name = "%s"
}`, name)
}
