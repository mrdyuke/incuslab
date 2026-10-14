resource "incus_storage_pool" "pool-1" {
  name   = "pool-1"
  driver = "dir"

  config = {
    source = "/var/lib/incus/storage-pools/pool-1"
  }
}
