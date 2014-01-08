module MinecraftSyncedMap
  require "thor"
  require 'colorize'

  class CommandLine < Thor

    desc "update", "sync map, generate, and update server"
    def update
      MinecraftSyncedMap::Base.set_settings!
      MinecraftSyncedMap::Base.download_map
      MinecraftSyncedMap::Base.generate_map
      MinecraftSyncedMap::Base.upload_map
    end

  end

end