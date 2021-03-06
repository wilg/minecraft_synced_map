require "minecraft_synced_map/version"
require 'colorize'
require 'yaml'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'fileutils'
require 'shellwords'

module MinecraftSyncedMap
  class Base

    def self.set_settings!(path = File.join(Dir.pwd, 'config' , 'mcmapsync.yml'))
      stored_settings = YAML.load_file(path).with_indifferent_access
      cache_dir = stored_settings[:cache_directory] || File.join(Dir.pwd, 'mcmapsync_cache')
      defaults = {
        cache_directory: cache_dir,
        world_directory: File.join(cache_dir, 'world'),
        map_directory: File.join(cache_dir, 'map'),
        tectonicus_config: File.join(Dir.pwd, 'config', 'tectonicus_config.xml'),
        overviewer_config: File.join(Dir.pwd, 'config', 'overviewer_config.py'),
        tectonicus_jar: File.join(Dir.pwd, 'vendor', 'Tectonicus_v2', 'Tectonicus_v2.19.jar'),
        overviewer_py: File.join(Dir.pwd, 'vendor', 'Minecraft-Overviewer', 'overviewer.py'),
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
      @@settings = defaults.merge(stored_settings).with_indifferent_access
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

    def self.download_world
      puts "Downloading world...".yellow
      FileUtils.mkpath settings[:world_directory]
      echo_command "boto-rsync #{boto_opts} s3://#{settings['world_bucket']}/#{settings['world_key']} #{settings[:world_directory].shellescape}"
    end

    def self.download_map
      puts "Downloading existing map...".yellow
      FileUtils.mkpath settings[:map_directory]
      if settings[:map_bucket]
        echo_command "boto-rsync #{boto_opts} s3://#{settings['map_bucket']}/#{settings['map_key']} #{settings[:map_directory].shellescape}"
      elsif settings[:map_rsync_domain]
        echo_command_sys "rsync -r -vv --size-only --modify-window=2 -z -e ssh #{settings[:map_rsync_domain]}:#{settings[:map_rsync_path]}map #{settings[:cache_directory].shellescape}"
      end
    rescue
      puts "Couldn't download existing map...".red
    end

    def self.generate_map
      puts "Generating map...".yellow
      # echo_command "java -Xms2048M -Xmx2048M -jar #{settings[:tectonicus_jar]} config=#{settings[:tectonicus_config]}"
      echo_command "WORLD_DIR=#{settings[:world_directory].shellescape} MAP_DIR=#{settings[:map_directory].shellescape} python #{settings[:overviewer_py]} --config=#{settings[:overviewer_config]} -v"
    end

    def self.generate_pois
      puts "Generating markers...".yellow
      echo_command "WORLD_DIR=#{settings[:world_directory].shellescape} MAP_DIR=#{settings[:map_directory].shellescape} python #{settings[:overviewer_py]} --config=#{settings[:overviewer_config]} --genpoi"
    end

    def self.upload_map
      puts "Uploading map...".yellow
      if settings[:map_bucket]
        echo_command "boto-rsync #{boto_opts} -g public-read #{settings[:map_directory].shellescape} s3://#{settings['map_bucket']}/#{settings['map_key']}"
      elsif settings[:map_rsync_domain]
        echo_command_sys "rsync -r -vv --size-only --modify-window=2 -z -e ssh #{settings[:map_directory].shellescape} #{settings[:map_rsync_domain]}:#{settings[:map_rsync_path]}"
      end
    end

    def self.echo_command(cmd)
      puts cmd.cyan
      puts `#{cmd}`
    end

    def self.echo_command_sys(cmd)
      puts cmd.cyan
      system `#{cmd}`
    end

  end
end
