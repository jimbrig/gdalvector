#  ------------------------------------------------------------------------
#
# Title : rclone setup for tigris
#    By : Jimmy Briggs
#  Date : 2026-06-17
#
#  ------------------------------------------------------------------------

if (!requireNamespace("rcloner")) {
  pak::pak("rcloner")
}

pkgload::load_all()

read_renviron()

rcloner::rclone_available()
rcloner::rclone_version()

tigris_rclone_config <- rcloner::rclone_config_create(
  name = "tigris",
  type = "s3",
  provider = "Other",
  access_key_id = Sys.getenv("TIGRIS_STORAGE_ACCESS_KEY_ID"),
  secret_access_key = Sys.getenv("TIGRIS_STORAGE_SECRET_ACCESS_KEY"),
  region = "auto",
  endpoint = Sys.getenv("TIGRIS_STORAGE_ENDPOINT")
)

rcloner::rclone_listremotes()

rcloner::rclone_lsd("tigris:noclocks-spatial")
