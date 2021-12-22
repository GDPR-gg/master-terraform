/* Copyright © 2019 VMware, Inc. All Rights Reserved.
   SPDX-License-Identifier: MPL-2.0 */

package nsxt

import (
	"fmt"
	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/terraform"
	"testing"
)

// NOTE: This test assumes single edge cluster on both sites
func TestAccResourceNsxtPolicyTier1Gateway_globalManager(t *testing.T) {
	testResourceName := "nsxt_policy_tier1_gateway.test"

	resource.Test(t, resource.TestCase{
		PreCheck: func() {
			testAccPreCheck(t)
			testAccOnlyGlobalManager(t)
			testAccEnvDefined(t, "NSXT_TEST_SITE_NAME")
			testAccEnvDefined(t, "NSXT_TEST_ANOTHER_SITE_NAME")
		},
		Providers: testAccProviders,
		CheckDestroy: func(state *terraform.State) error {
			return testAccNsxtPolicyTier1CheckDestroy(state, defaultTestResourceName)
		},
		Steps: []resource.TestStep{
			{
				Config: testAccNsxtPolicyTier1GMCreateTemplate(true),
				Check: resource.ComposeTestCheckFunc(
					testAccNsxtPolicyTier1Exists(testResourceName),
					resource.TestCheckResourceAttr(testResourceName, "display_name", defaultTestResourceName),
					resource.TestCheckResourceAttr(testResourceName, "tier0_path", ""),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_types.#", "2"),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_rule.#", "0"),
					resource.TestCheckResourceAttr(testResourceName, "locale_service.#", "1"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.#", "1"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.0.transit_subnet", testAccGmGatewayIntersiteSubnet),
					resource.TestCheckResourceAttrSet(testResourceName, "intersite_config.0.primary_site_path"),
					resource.TestCheckResourceAttrSet(testResourceName, "path"),
					resource.TestCheckResourceAttrSet(testResourceName, "revision"),
				),
			},
			{
				Config: testAccNsxtPolicyTier1GMUpdateTemplate(),
				Check: resource.ComposeTestCheckFunc(
					testAccNsxtPolicyTier1Exists(testResourceName),
					resource.TestCheckResourceAttr(testResourceName, "display_name", defaultTestResourceName),
					resource.TestCheckResourceAttr(testResourceName, "tier0_path", ""),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_types.#", "2"),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_rule.#", "1"),
					resource.TestCheckResourceAttr(testResourceName, "locale_service.#", "2"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.#", "1"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.0.transit_subnet", testAccGmGatewayIntersiteSubnet),
					resource.TestCheckResourceAttrSet(testResourceName, "intersite_config.0.primary_site_path"),
					resource.TestCheckResourceAttrSet(testResourceName, "path"),
					resource.TestCheckResourceAttrSet(testResourceName, "revision"),
				),
			},
			{
				Config: testAccNsxtPolicyTier1GMMinimalistic(),
				Check: resource.ComposeTestCheckFunc(
					testAccNsxtPolicyTier1Exists(testResourceName),
					resource.TestCheckResourceAttr(testResourceName, "display_name", defaultTestResourceName),
					resource.TestCheckResourceAttr(testResourceName, "tier0_path", ""),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_types.#", "0"),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_rule.#", "0"),
					resource.TestCheckResourceAttr(testResourceName, "locale_service.#", "0"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.#", "1"),
					resource.TestCheckResourceAttrSet(testResourceName, "path"),
					resource.TestCheckResourceAttrSet(testResourceName, "revision"),
				),
			},
		},
	})
}

// NOTE: This test assumes single edge cluster on both sites
func TestAccResourceNsxtPolicyTier1Gateway_globalManagerNoSubnet(t *testing.T) {
	testResourceName := "nsxt_policy_tier1_gateway.test"

	resource.Test(t, resource.TestCase{
		PreCheck: func() {
			testAccPreCheck(t)
			testAccOnlyGlobalManager(t)
			testAccEnvDefined(t, "NSXT_TEST_SITE_NAME")
			testAccEnvDefined(t, "NSXT_TEST_ANOTHER_SITE_NAME")
		},
		Providers: testAccProviders,
		CheckDestroy: func(state *terraform.State) error {
			return testAccNsxtPolicyTier1CheckDestroy(state, defaultTestResourceName)
		},
		Steps: []resource.TestStep{
			{
				Config: testAccNsxtPolicyTier1GMCreateTemplate(false),
				Check: resource.ComposeTestCheckFunc(
					testAccNsxtPolicyTier1Exists(testResourceName),
					resource.TestCheckResourceAttr(testResourceName, "display_name", defaultTestResourceName),
					resource.TestCheckResourceAttr(testResourceName, "tier0_path", ""),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_types.#", "2"),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_rule.#", "0"),
					resource.TestCheckResourceAttr(testResourceName, "locale_service.#", "1"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.#", "1"),
					resource.TestCheckResourceAttrSet(testResourceName, "intersite_config.0.transit_subnet"),
					resource.TestCheckResourceAttrSet(testResourceName, "intersite_config.0.primary_site_path"),
					resource.TestCheckResourceAttrSet(testResourceName, "path"),
					resource.TestCheckResourceAttrSet(testResourceName, "revision"),
				),
			},
			{
				Config: testAccNsxtPolicyTier1GMUpdateTemplate(),
				Check: resource.ComposeTestCheckFunc(
					testAccNsxtPolicyTier1Exists(testResourceName),
					resource.TestCheckResourceAttr(testResourceName, "display_name", defaultTestResourceName),
					resource.TestCheckResourceAttr(testResourceName, "tier0_path", ""),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_types.#", "2"),
					resource.TestCheckResourceAttr(testResourceName, "route_advertisement_rule.#", "1"),
					resource.TestCheckResourceAttr(testResourceName, "locale_service.#", "2"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.#", "1"),
					resource.TestCheckResourceAttr(testResourceName, "intersite_config.0.transit_subnet", testAccGmGatewayIntersiteSubnet),
					resource.TestCheckResourceAttrSet(testResourceName, "intersite_config.0.primary_site_path"),
					resource.TestCheckResourceAttrSet(testResourceName, "path"),
					resource.TestCheckResourceAttrSet(testResourceName, "revision"),
				),
			},
		},
	})
}

func testAccNsxtPolicyTier1GMCreateTemplate(withSubnet bool) string {

	subnet := ""
	if withSubnet {
		subnet = fmt.Sprintf(`transit_subnet = "%s"`, testAccGmGatewayIntersiteSubnet)
	}
	return testAccNsxtPolicyGMGatewayDeps() + fmt.Sprintf(`
resource "nsxt_policy_tier1_gateway" "test" {
  display_name              = "%s"
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]

  locale_service {
    edge_cluster_path    = data.nsxt_policy_edge_cluster.ec_site1.path
    preferred_edge_paths = [data.nsxt_policy_edge_node.en_site1.path]
  }

  intersite_config {
    primary_site_path = data.nsxt_policy_site.site1.path
    %s
  }
}`, defaultTestResourceName, subnet)
}

func testAccNsxtPolicyTier1GMUpdateTemplate() string {
	return testAccNsxtPolicyGMGatewayDeps() + fmt.Sprintf(`
resource "nsxt_policy_tier1_gateway" "test" {
  display_name              = "%s"
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]

  route_advertisement_rule {
    name            = "rule1"
    action          = "PERMIT"
    subnets         = ["30.0.0.0/24", "31.0.0.0/24"]
    prefix_operator = "GE"
  }

  locale_service {
    edge_cluster_path    = data.nsxt_policy_edge_cluster.ec_site1.path
    preferred_edge_paths = [data.nsxt_policy_edge_node.en_site1.path]
  }

  locale_service {
    edge_cluster_path = data.nsxt_policy_edge_cluster.ec_site2.path
  }

  intersite_config {
    primary_site_path = data.nsxt_policy_site.site2.path
    transit_subnet    = "%s"
  }
}`, defaultTestResourceName, testAccGmGatewayIntersiteSubnet)
}

func testAccNsxtPolicyTier1GMMinimalistic() string {
	return testAccNsxtPolicyGMGatewayDeps() + fmt.Sprintf(`
resource "nsxt_policy_tier1_gateway" "test" {
  display_name = "%s"
}`, defaultTestResourceName)
}
