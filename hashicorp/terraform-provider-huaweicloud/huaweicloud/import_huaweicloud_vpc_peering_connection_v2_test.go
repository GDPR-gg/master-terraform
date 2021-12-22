package huaweicloud

import (
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
)

func TestAccOTCVpcPeeringConnectionV1_importBasic(t *testing.T) {
	resourceName := "huaweicloud_vpc_peering_connection_v2.peering_1"

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckVpcPeeringConnectionV2Destroy,
		Steps: []resource.TestStep{
			{
				Config: testAccVpcPeeringConnectionV2_basic,
			},

			{
				ResourceName:      resourceName,
				ImportState:       true,
				ImportStateVerify: true,
			},
		},
	})
}
