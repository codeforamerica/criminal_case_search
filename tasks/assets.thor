require 'sinatra/asset_pipeline/task.rb'
require File.dirname(__FILE__) + '/../datashare_filter.rb'
require 'pry'

# Adapted for Thor from
# https://github.com/kalasjocke/sinatra-asset-pipeline/blob/master/lib/sinatra/asset_pipeline/task.rb
class Assets < Thor
  desc "precompile", "precompiles the assets"
  def precompile
    app_klass = DatashareFilter
    environment = app_klass.sprockets
    manifest = Sprockets::Manifest.new(environment.index, app_klass.assets_path)
    manifest.compile(app_klass.assets_precompile)
    # binding.pry
  end

  desc "clean", "deletes precompiled assets"
  def clean
    FileUtils.rm_rf(DatashareFilter.assets_path)
  end
end
