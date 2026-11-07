package provider

import (
	"context"
	"fmt"
	"testing"

	"github.com/Agora-Calyce/terraform-provider-spx/internal/client"

	"github.com/hashicorp/terraform-plugin-framework/diag"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-testing/helper/resource"
)

func TestEipResourceMapping(t *testing.T) {
	ctx := context.Background()
	r := &eipResource{}

	model := &eipResourceModel{}
	eip := &client.Eip{
		ID:         "eip-123",
		Name:       "test-eip",
		SubnetId:   "sub-123",
		InternalIP: "10.0.0.1",
		ExternalIP: "1.2.3.4",
		Nat:        "fip",
		SNAT:       []string{"10.0.0.2"},
		DNAT: []client.EipDNAT{
			{
				ExternalPort: "80",
				InternalIP:   "10.0.0.1",
				InternalPort: "8080",
				Protocol:     "tcp",
			},
		},
	}

	diags := &diag.Diagnostics{}
	r.mapEipToModel(ctx, model, eip, "orga-123", "az-123", "proj-123", diags)

	if diags.HasError() {
		t.Fatalf("mapping failed: %v", diags)
	}

	if model.ID.ValueString() != "eip-123" {
		t.Errorf("expected ID eip-123, got %s", model.ID.ValueString())
	}
	if model.ExternalIP.ValueString() != "1.2.3.4" {
		t.Errorf("expected ExternalIP 1.2.3.4, got %s", model.ExternalIP.ValueString())
	}
	if len(model.DNAT) != 1 {
		t.Errorf("expected 1 DNAT rule, got %d", len(model.DNAT))
	} else {
		if model.DNAT[0].ExternalPort.ValueString() != "80" {
			t.Errorf("expected DNAT ExternalPort 80, got %s", model.DNAT[0].ExternalPort.ValueString())
		}
	}
}

func TestEipResourceMapping_DNATKeepsPriorOrder(t *testing.T) {
	ctx := context.Background()
	r := &eipResource{}

	model := &eipResourceModel{DNAT: []eipDNATModel{
		{ExternalPort: types.StringValue("80"), InternalIP: types.StringValue("10.0.0.10"), InternalPort: types.StringValue("80"), Protocol: types.StringValue("tcp")},
		{ExternalPort: types.StringValue("22"), InternalIP: types.StringValue("10.0.0.10"), InternalPort: types.StringValue("22"), Protocol: types.StringValue("tcp")},
	}}
	eip := &client.Eip{
		ID: "eip-123",
		DNAT: []client.EipDNAT{
			{ExternalPort: "443", InternalIP: "10.0.0.10", InternalPort: "443", Protocol: "tcp"},
			{ExternalPort: "22", InternalIP: "10.0.0.10", InternalPort: "22", Protocol: "tcp"},
			{ExternalPort: "80", InternalIP: "10.0.0.10", InternalPort: "80", Protocol: "tcp"},
		},
	}

	var diags diag.Diagnostics
	r.mapEipToModel(ctx, model, eip, "orga", "az", "project", &diags)
	if diags.HasError() {
		t.Fatalf("unexpected diagnostics: %v", diags)
	}

	want := []string{"80", "22", "443"}
	if len(model.DNAT) != len(want) {
		t.Fatalf("expected %d DNAT rules, got %d", len(want), len(model.DNAT))
	}
	for i, port := range want {
		if got := model.DNAT[i].ExternalPort.ValueString(); got != port {
			t.Errorf("DNAT[%d]: expected external port %s, got %s", i, port, got)
		}
	}
}

func TestAccEipResource(t *testing.T) {
	resourceName := "spx_eip.test"
	vpcName := "terraform-test-vpc-for-eip"
	subnetName := "terraform-test-subnet-for-eip"
	eipName := "terraform-test-eip"

	resource.Test(t, resource.TestCase{
		PreCheck:                 func() { testAccPreCheck(t) },
		ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
		Steps: []resource.TestStep{
			{
				Config: testAccEipResourceConfig(vpcName, subnetName, eipName),
				Check: resource.ComposeTestCheckFunc(
					resource.TestCheckResourceAttr(resourceName, "name", eipName),
					resource.TestCheckResourceAttrSet(resourceName, "id"),
					resource.TestCheckResourceAttrSet(resourceName, "subnet_id"),
				),
			},
			{
				ResourceName:      resourceName,
				ImportState:       true,
				ImportStateVerify: true,
			},
		},
	})
}

func testAccEipResourceConfig(vpcName, subnetName, eipName string) string {
	return fmt.Sprintf(`
provider "spx" {
  orga_id    = "%s"
  project_id = "%s"
  az         = "%s"
}

resource "spx_vpc" "test" {
  name = "%s"
}

resource "spx_subnet" "test" {
  name       = "%s"
  vpc_id     = spx_vpc.test.id
  ipv4       = "10.0.1.0/24"
  private    = true
  protocol   = "IPv4"
  nat_gateway = false
}

resource "spx_eip" "test" {
  name      = "%s"
  subnet_id = spx_subnet.test.id
}
`, testOrgaId, testProjectId, testAz, vpcName, subnetName, eipName)
}
