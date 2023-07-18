#---------------------------------------------------------
# Storage Account Creation or selection 
#----------------------------------------------------------
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}
