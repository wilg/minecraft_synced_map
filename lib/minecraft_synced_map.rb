require "minecraft_synced_map/version"
require 'colorize'
require 'yaml'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'fileutils'

module MinecraftSyncedMap
  class Base

    def self.set_settings!(path = File.join(Dir.pwd, 'config' , 'mcmapsync.yml'))
      defaults = {
        world_directory: File.join(Dir.pwd, 'mcmapsync_cache', 'world'),
        map_directory: File.join(Dir.pwd, 'mcmapsync_cache', 'map'),
        tectonicus_config: File.join(Dir.pwd, 'config', 'tectonicus_config.xml'),
        tectonicus_jar: File.join(Dir.pwd, 'vendor', 'Tectonicus_v2', 'Tectonicus_v2.19.jar'),
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
      @@settings = defaults.merge(YAML.load_file(path).with_indifferent_access).with_indifferent_access
    end

    def self.settings
      @@settings
    end

    def self.credential_env
      "AWS_ACCESS_KEY_ID=#{settings[:aws_access_key_id]} AWS_SECRET_ACCESS_KEY=#{settings[:aws_secret_access_key]}"
    end

    def self.boto_opts
      "-a #{settings[:aws_access_key_id]} -s #{settings[:aws_secret_access_key]}"
    end

    def self.download_map
      puts "Downloading world...".yellow
      FileUtils.mkpath settings[:world_directory]
      echo_command "boto-rsync #{boto_opts} s3://#{settings['world_bucket']}/#{settings['world_key']} #{settings[:world_directory]}"
      puts "Downloading existing map...".yellow
      FileUtils.mkpath settings[:map_directory]
      echo_command "boto-rsync #{boto_opts} s3://#{settings['map_bucket']}/#{settings['map_key']} #{settings[:map_directory]}"
    end

    def self.generate_map
      puts "Generating map...".yellow
      echo_command "java -Xms2048M -Xmx2048M -jar #{settings[:tectonicus_jar]} config=#{settings[:tectonicus_config]}"
    end

    def self.upload_map
      puts "Uploading map...".yellow
      echo_command "boto-rsync #{boto_opts} -g public-read #{settings[:map_directory]} s3://#{settings['map_bucket']}/#{settings['map_key']}"
    end

    def self.echo_command(cmd)
      puts cmd.cyan
      puts `#{cmd}`
    end

  end
end
