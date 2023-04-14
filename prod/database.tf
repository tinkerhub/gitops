resource "digitalocean_database_cluster" "postgres_cluster" {
  lifecycle {
    prevent_destroy = true
  }
  # Name of the database
  name = "platform-database-cluster"
  # The database engine to use. Currently Postgres. Could be MySql or Redis
  engine = "pg"
  # Version of the engine. So Postgres 11
  version = var.pg_version
  # Size of the database instance
  size = var.database_size
  # Region to deploy the database to
  region = local.regions.india
  # How many database nodes do we want
  node_count = 1
  # VPC to put the 
  private_network_uuid = digitalocean_vpc.main.id
}

resource "digitalocean_database_firewall" "postgress_cluster_firewall" {
  # Database cluster ID to associate this firewall rule with
  cluster_id = digitalocean_database_cluster.postgres_cluster.id

  rule {
    type  = "tag"
    value = "platform-server"
  }

  rule {
    type  = "ip_addr"
    value = "103.82.158.140"
  }
}
