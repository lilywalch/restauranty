variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["auth", "discounts", "items", "client"]
}

target "common" {
  platforms = ["linux/amd64"]
  cache-from = ["type=registry,ref=lilywalch/restauranty-buildcache:cache"]
  cache-to = ["type=registry,ref=lilywalch/restauranty-buildcache:cache,mode=max"]
}

target "auth" {
  inherits = ["common"]
  context = "./backend/auth"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-auth-service:${TAG}"]
}

target "discounts" {
  inherits = ["common"]
  context = "./backend/discounts"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-discounts-service:${TAG}"]
}

target "items" {
  inherits = ["common"]
  context = "./backend/items"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-items-service:${TAG}"]
}

target "client" {
  inherits = ["common"]
  context = "./client"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-client-service:${TAG}"]
}