resource "digitalocean_reserved_ip" "platform" {
  droplet_id = digitalocean_droplet.main.id
  region     = digitalocean_droplet.main.region
}

resource "cloudflare_record" "platform_domain" {
  zone_id = var.cloudflare_zone_id
  name    = "gamma"
  value   = digitalocean_reserved_ip.platform.ip_address
  type    = "A"
  ttl     = 1

  proxied = true
}

resource "cloudflare_record" "platform_ssh_domain" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh.gamma"
  value   = digitalocean_reserved_ip.platform.ip_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "nocodb_domain" {
  zone_id = var.cloudflare_zone_id
  name    = "admin"
  value   = digitalocean_reserved_ip.platform.ip_address
  type    = "A"
  ttl     = 1

  proxied = true
}

