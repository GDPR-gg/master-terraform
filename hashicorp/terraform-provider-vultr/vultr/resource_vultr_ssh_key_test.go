package vultr

import (
	"context"
	"fmt"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/helper/acctest"
	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/terraform"
)

func TestAccVultrSSHKey_basic(t *testing.T) {
	rInt := acctest.RandInt()
	rSSH, _, err := acctest.RandSSHKeyPair("foobar")

	if err != nil {
		t.Fatalf("Error generating test SSH key pair: %s", err)
	}

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckVultrSSHKeyDestroy,
		Steps: []resource.TestStep{
			{
				Config: testAccVultrSSHKeyConfigBasic(rInt, rSSH),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckVultrSSHKeyExists("vultr_ssh_key.foo"),
					resource.TestCheckResourceAttr("vultr_ssh_key.foo", "name", fmt.Sprintf("foo-%d", rInt)),
					resource.TestCheckResourceAttr("vultr_ssh_key.foo", "ssh_key", fmt.Sprintf("%s", rSSH)),
					resource.TestCheckResourceAttrSet("vultr_ssh_key.foo", "date_created"),
				),
			},
			{
				Config: testAccVultrSSHKeyConfigUpdate(rInt, rSSH),
				Check: resource.ComposeTestCheckFunc(
					testAccCheckVultrSSHKeyExists("vultr_ssh_key.foo"),
					resource.TestCheckResourceAttr("vultr_ssh_key.foo", "name", fmt.Sprintf("bar-%d", rInt)),
					resource.TestCheckResourceAttr("vultr_ssh_key.foo", "ssh_key", fmt.Sprintf("%s", rSSH)),
					resource.TestCheckResourceAttrSet("vultr_ssh_key.foo", "date_created"),
				),
			},
		},
	})
}

func testAccCheckVultrSSHKeyDestroy(s *terraform.State) error {
	for _, rs := range s.RootModule().Resources {
		if rs.Type != "vultr_ssh_key" {
			continue
		}

		keyID := rs.Primary.ID
		client := testAccProvider.Meta().(*Client).govultrClient()

		keys, err := client.SSHKey.List(context.Background())
		if err != nil {
			return fmt.Errorf("Error getting SSH keys: %s", err)
		}

		exists := false
		for i := range keys {
			if keys[i].SSHKeyID == keyID {
				exists = true
				break
			}
		}

		if exists {
			return fmt.Errorf("SSH Key still exists: %s", keyID)
		}
	}
	return nil
}

func testAccCheckVultrSSHKeyExists(n string) resource.TestCheckFunc {
	return func(s *terraform.State) error {
		rs, ok := s.RootModule().Resources[n]
		if !ok {
			return fmt.Errorf("Not found: %s", n)
		}

		if rs.Primary.ID == "" {
			return fmt.Errorf("SSH Key ID is not set")
		}

		keyID := rs.Primary.ID
		client := testAccProvider.Meta().(*Client).govultrClient()

		keys, err := client.SSHKey.List(context.Background())
		if err != nil {
			return fmt.Errorf("Error getting SSH keys: %s", err)
		}

		exists := false
		for i := range keys {
			if keys[i].SSHKeyID == keyID {
				exists = true
				break
			}
		}

		if !exists {
			return fmt.Errorf("SSH Key does not exist: %s", keyID)
		}

		return nil
	}
}

func testAccVultrSSHKeyConfigBasic(rInt int, rSSH string) string {
	return fmt.Sprintf(`
		resource "vultr_ssh_key" "foo" {
			name       = "foo-%d"
			ssh_key = "%s"
		}
	`, rInt, rSSH)
}

func testAccVultrSSHKeyConfigUpdate(rInt int, rSSH string) string {
	return fmt.Sprintf(`
		resource "vultr_ssh_key" "foo" {
			name       = "bar-%d"
			ssh_key = "%s"
		}
	`, rInt, rSSH)
}
