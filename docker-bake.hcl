group "default" {
  targets = ["auth", "discounts", "items", "client"]
}

target "common" {
  platforms = ["linux/amd64", "linux/arm64"]
  cache-from = ["type=registry,ref=lilywalch/restauranty-buildcache:cache"]
  cache-to = ["type=registry,ref=lilywalch/restauranty-buildcache:cache,mode=max"]
}

target "auth" {
  inherits = ["common"]
  context = "./backend/auth"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-auth-service:latest"]
}

target "discounts" {
  inherits = ["common"]
  context = "./backend/discounts"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-discounts-service:latest"]
}

target "items" {
  inherits = ["common"]
  context = "./backend/items"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-items-service:latest"]
}

target "client" {
  inherits = ["common"]
  context = "./client"
  dockerfile = "Dockerfile"
  tags = ["lilywalch/restauranty-client-service:latest"]
}