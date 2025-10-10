# .tflint.hcl - Simplified and Corrected

plugin "google" {
  enabled = true
  # Provide the full source path for the HashiCorp Google provider
  source  = "github.com/terraform-linters/tflint-ruleset-google"
  version = "0.22.0"
}
