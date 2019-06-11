Capistrano::Configuration.instance.load do
  after 'deploy:update_code', 'a9n:copy_stage_config'

  namespace :a9n do
    desc 'Copy stage configuration to base file.'
    task :copy_stage_config, roles: :app do
      run "cp #{fetch(:release_path)}/config/configuration.yml.#{fetch(:stage)} #{fetch(:release_path)}/config/configuration.yml"
    end
  end
end
