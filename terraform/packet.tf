provider "metal" {}

output "deploy_targets" {
  value = merge(
      {for e in metal_device.agents: e.hostname => {
        ip = e.network.0.address
        expression = "{ }"
      }},
  )
}

variable "agents" {
  default = 1
}

variable "project_id" {
  default = "86d5d066-b891-4608-af55-a481aa2c0094"
}

variable "bootstrap_expr" {
  default = <<EXPR
{
  users.users.root.openssh.authorizedKeys.keys = [
    ''cert-authority,principals="root" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYz52kl4UpY55Q/D9AUPY705XfbVwUxZwDzigBisrpvFozR3sZSXMnJxcUm98E7cBDk0zAIi3A+RiWzj7c97UWBRrPnKAqGKAaOVS969Qzp5rR4PV/SV2Af6P2oSnQvQngkdt1ygxq0tA63nzLpjdpx6DAi+Ce91QJCFGL/ksSIIPrR3TW9vfeZGWNewPYueNeuvqlhq4iAs8a8eKqzG+8T5vjhbVXjVHv7iQLy0Rr9k+e7FyyKhr0KblMMXRzrioHV3LEsaQc8To+0+/cDnhD/QkgJ7HTTBZNAtJ8WikNY8B07rOLUcgj0F6fBPN+lzar6eDeFca2TW2AxvCOfkvIajJEIs9ETiTVJ5PHHmLSsc7fHd2e6SOubReWuibBEpunXkbCdTzQ0IK7Enm5osXzZLVC++SWsZBa6gJ/W1O93dwdQ1RLxQrZCZ7xuERZvlWOPYBQLDDigR8AYMPgYYspnHbRBKEPDgxgVRFKXEnGQqXbeypveWkw2X3eVO1Dp9k+74hdZGE53y9TBgX46P2gSDrv2EgPgqHkyx9pyz1ueT+LdydDWrNDEjokBkYq9A+O2qJZH8W0Wk+N5BYyZBgbUPBHOXTOQ3HQnN54CIuswXK2oD1Rj9XEnEX5okSt5sP5/gqzE/FEk2as9TERcRtHuz9Fvu6LTHka+TaUtfMtuw==''
   ];
}
EXPR
}

resource "metal_device" "agents" {
  count            = var.agents
  project_id       = var.project_id
  hostname         = "buildkite-spot-${count.index}"
  billing_cycle    = "hourly"
  operating_system = "custom_ipxe"
  plan             = "m1.xlarge.x86"
  facilities       = ["ewr1"]

  user_data = <<USERDATA
#!nix
${var.bootstrap_expr}
USERDATA

  ipxe_script_url     = "https://netboot.gsc.io/installer-pre2/x86/netboot.ipxe"
  always_pxe       = false
  tags                = concat(var.tags, ["buildkite-agent", "skip-hydra"])

  lifecycle {
    ignore_changes = [ user_data ]
  }
}

