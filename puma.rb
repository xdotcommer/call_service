port ENV.fetch("PORT") { 4567 }
environment ENV.fetch("RACK_ENV") { "development" }
# Preload the app for performance
preload_app!