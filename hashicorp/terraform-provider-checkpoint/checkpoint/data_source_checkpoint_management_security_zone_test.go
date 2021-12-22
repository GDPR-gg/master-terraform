package checkpoint

import (
	"fmt"
	"github.com/hashicorp/terraform-plugin-sdk/helper/acctest"
	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
	"os"
	"testing"
)

func TestAccDataSourceCheckpointManagementSecurityZone_basic(t *testing.T) {

	objName := "tfTestManagementDataSecurityZone_" + acctest.RandString(6)
	resourceName := "checkpoint_management_security_zone.security_zone"
	dataSourceName := "data.checkpoint_management_data_security_zone.data_security_zone"

	context := os.Getenv("CHECKPOINT_CONTEXT")
	if context != "web_api" {
		t.Skip("Skipping management test")
	}

	resource.Test(t, resource.TestCase{
		PreCheck:  func() { testAccPreCheck(t) },
		Providers: testAccProviders,
		Steps: []resource.TestStep{
			{
				Config: testAccDataSourceManagementSecurityZoneConfig(objName),
				Check: resource.ComposeTestCheckFunc(
					resource.TestCheckResourceAttrPair(dataSourceName, "name", resourceName, "name"),
				),
			},
		},
	})

}

func testAccDataSourceManagementSecurityZoneConfig(name string) string {
	return fmt.Sprintf(`
resource "checkpoint_management_security_zone" "security_zone" {
    name = "%s"
}

data "checkpoint_management_data_security_zone" "data_security_zone" {
    name = "${checkpoint_management_security_zone.security_zone.name}"
}
`, name)
}
