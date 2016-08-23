# TODO: Generalise this class and use for other stylesheets
class TeamStylesheet
  def initialize(team)
    @team = team
    @tenant = LandLord.new(@team).tenant
  end

  # This setups up the directories
  def self.initial_setup

    # Delete all sass files in development
    if Rails.env.development?
      self.clear_all
    end

    # Create directories for dynamic assets
    dynamic_asset_dirs = %w[teams]
    dynamic_asset_dirs.each do |dir|
      FileUtils.mkpath "app/assets/stylesheets/dynamic/" + dir
    end
  end

  # The path of the compiled stylesheet, i.e. stores/id_timestamp.css
  def stylesheet_file
    filename = [
      @team.id,
      @team.updated_at.to_s(:number)
    ].join('_')

    # HACK - to make it work on test enironment
    if Rails.env.test?
      filename = [
        @team.id
      ].join('_')
    end
    

    File.join \
      'dynamic',
      'teams',
      "#{filename}.css"
  end

  # The path of the uncompiled Sass file, i.e. /path/to/app/app/assets/stylesheets/stores/id_timestamp.css.scss
  def sass_file_path
    Rails.root.join('app', 'assets', 'stylesheets', "#{self.stylesheet_file}.scss")
  end

  # The styles which are rendered through app/views/stores/styles.scss.erb
  # You can supply local variables which can be accessed in the style view.
  def styles
    TeamsController.new.render_to_string 'styles',
      formats: [:scss],
      layout:  false,
      locals:  { team: @team, tenant: @tenant }
  end

  # Check if this stylesheet has been compiled or needs to be recompiled
  def compiled?
    if Rails.application.config.assets.compile
      # If assets are compiled dynamically, check if the Sass file exists and is not empty
      File.exists?(self.sass_file_path) && !File.zero?(self.sass_file_path)
    else
      # Otherwise check if the digested file is registered as an asset
      Rails.application.config.assets.digests[self.stylesheet_file].present?
    end
  end

  def compile
    # Compile app/views/stores/styles.scss.erb into app/assets/stylesheets/stores/id-timestamp.css.scss
    File.open(self.sass_file_path, 'w') { |f| f.write(self.styles) }

    # Create and register digested file only if assets are not compiled dynamically
    unless Rails.application.config.assets.compile
      # Use Sprockets::Environment instead of Sprockets::Index to find the dynamically created asset.
      # Rails.application.assets might be a Sprockets::Index (in production) or a Sprockets::Environment (in development)
      # We need to access the Sprockets::Environment to find the file that was just compiled. Sprockets::Index caches everything and wouldn't find this file.
      # TODO: Is there an easier way to access the Sprockets::Environment?
      env = Rails.application.assets.is_a?(Sprockets::Index) ? Rails.application.assets.instance_variable_get('@environment') : Rails.application.assets

      # Compile asset
      Sprockets::StaticCompiler.new(
        env,
        File.join(Rails.public_path, Rails.application.config.assets.prefix),
        [self.stylesheet_file],
        digest:   false,
        manifest: false
      ).compile

      # Register digested file as an asset
      Rails.application.config.assets.digests[self.stylesheet_file] = env[self.stylesheet_file].digest_path
    end

    # Delete old files
    Dir[self.sass_file_path.sub(/\d+.css.scss$/, '*')].each do |file|
      File.delete file unless file == self.sass_file_path.to_s
    end

    self
  end

  def self.clear_all
    Dir["app/assets/stylesheets/dynamic/*/**"].each do |file|
        File.delete file
    end
  end
end