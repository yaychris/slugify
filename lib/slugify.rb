module Slugify
  def slugify(from_field = :title, options = {})
    options.symbolize_keys!
    options.reverse_merge!({
      :from    => from_field,
      :to      => :slug
    })

    # Save the options
    cattr_accessor :slugify_options
    self.slugify_options = options

    # Define #slugify
    define_method(:slugify) do |*args|
      force_refresh = args.first || false

      from = self.class.slugify_options[:from]
      to   = self.class.slugify_options[:to]

      return if self[from].nil?

      self[to] = if self[to].blank? || force_refresh
        # only process from field if slug is blank
        self[from].parameterize.to_s
      else
        # always parameterize the slug field, in case the user gives invalid input
        self[to].parameterize.to_s
      end
    end

    # Define #slugify!
    define_method(:slugify!) do
      slugify(true)
    end

    ##
    # Install validations
    validates_presence_of self.slugify_options[:to]
    validates_uniqueness_of self.slugify_options[:to]
    validates_format_of self.slugify_options[:to], :with => /^[-_+a-z0-9]+$/

    ##
    # Install filters
    before_validation :slugify

    # slugify after create so that the new id can be set
    after_create :slugify
  end
end

ActiveRecord::Base.extend(Slugify)
