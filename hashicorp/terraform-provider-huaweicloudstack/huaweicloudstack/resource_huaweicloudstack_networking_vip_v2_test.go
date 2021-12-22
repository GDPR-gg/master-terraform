package huaweicloudstack

import (
	"fmt"
	"log"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/helper/acctest"
	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/terraform"
	"github.com/huaweicloud/golangsdk/openstack/networking/v2/ports"
)

func TestAccNetworkingV2VIP_basic(t *testing.T) {
	var vip ports.Port
	var routerName = fmt.Sprintf("acc_router_%s", acctest.RandString(5))

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckNetworkingV2VIPDestroy,
		Steps: []resource.TestStep{
			{
				Config: testAccNetworkingV2VIPConfig_basic(routerName),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckNetworkingV2VIPExists("huaweicloudstack_networking_vip_v2.vip_1", &vip),
				),
			},
		},
	})
}

func testAccCheckNetworkingV2VIPDestroy(s *terraform.State) error {
	config := testAccProvider.Meta().(*Config)
	networkingClient, err := config.networkingV2Client(OS_REGION_NAME)
	if err != nil {
		return fmt.Errorf("Error creating HuaweiCloudStack networking client: %s", err)
	}

	for _, rs := range s.RootModule().Resources {
		if rs.Type != "huaweicloudstack_networking_vip_v2" {
			continue
		}

		_, err := ports.Get(networkingClient, rs.Primary.ID).Extract()
		if err == nil {
			return fmt.Errorf("VIP still exists")
		}
	}

	log.Printf("[DEBUG] testAccCheckNetworkingV2VIPDestroy success!")

	return nil
}

func testAccCheckNetworkingV2VIPExists(n string, vip *ports.Port) resource.TestCheckFunc {
	return func(s *terraform.State) error {
		rs, ok := s.RootModule().Resources[n]
		if !ok {
			return fmt.Errorf("Not found: %s", n)
		}

		if rs.Primary.ID == "" {
			return fmt.Errorf("No ID is set")
		}

		config := testAccProvider.Meta().(*Config)
		networkingClient, err := config.networkingV2Client(OS_REGION_NAME)
		if err != nil {
			return fmt.Errorf("Error creating HuaweiCloudStack networking client: %s", err)
		}

		found, err := ports.Get(networkingClient, rs.Primary.ID).Extract()
		if err != nil {
			return err
		}

		if found.ID != rs.Primary.ID {
			return fmt.Errorf("VIP not found")
		}
		log.Printf("[DEBUG] test found is: %#v", found)
		*vip = *found

		return nil
	}
}

func testAccNetworkingV2VIPConfig_basic(routerName string) string {
	return fmt.Sprintf(`
resource "huaweicloudstack_networking_network_v2" "network_1" {
  name = "network_1"
  admin_state_up = "true"
}

resource "huaweicloudstack_networking_subnet_v2" "subnet_1" {
  name = "subnet_1"
  cidr = "192.168.199.0/24"
  ip_version = 4
  network_id = "${huaweicloudstack_networking_network_v2.network_1.id}"
}

resource "huaweicloudstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${huaweicloudstack_networking_router_v2.router_acc.id}"
  subnet_id = "${huaweicloudstack_networking_subnet_v2.subnet_1.id}"
}

resource "huaweicloudstack_networking_router_v2" "router_acc" {
  name = "%s"
  external_gateway = "%s"
}

resource "huaweicloudstack_networking_vip_v2" "vip_1" {
  network_id = "${huaweicloudstack_networking_network_v2.network_1.id}"
  subnet_id = "${huaweicloudstack_networking_subnet_v2.subnet_1.id}"
}
`, routerName, OS_EXTGW_ID)
}
