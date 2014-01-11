module MinecraftSyncedMap
  require "thor"
  require 'colorize'

  class CommandLine < Thor

    desc "update", "sync map, generate, and update server"
    def update
      pull
      build
      build_poi
      push
    end

    desc 'pull', "pull map from server"
    def pull
      MinecraftSyncedMap::Base.set_settings!
      MinecraftSyncedMap::Base.download_world
      MinecraftSyncedMap::Base.download_map
    end

    desc 'build', "build map tiles locally"
    def build
      MinecraftSyncedMap::Base.set_settings!
      MinecraftSyncedMap::Base.generate_map
    end

    desc 'build_poi', "build poi cache"
    def build_poi
      MinecraftSyncedMap::Base.set_settings!
      MinecraftSyncedMap::Base.generate_pois
    end

    desc 'push', "push map to server"
    def push
      MinecraftSyncedMap::Base.set_settings!
      MinecraftSyncedMap::Base.upload_map
    end

  end

end