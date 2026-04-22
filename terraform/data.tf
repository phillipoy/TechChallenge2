########################################
# DATA SOURCES
########################################
# Data sources are used to fetch existing AWS information
# instead of creating new resources.

# Get list of available Availability Zones in the region
# Used to spread subnets across zones for high availability
data "aws_availability_zones" "available" {
  state = "available"
}