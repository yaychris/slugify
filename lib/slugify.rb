module Slugify
  class MissingColumnError < StandardError; end

  def slugify(from_field = :title, options = {})
    options.symbolize_keys!
    options.reverse_merge!({
      :from   => from_field,
      :to     => :slug,
      :force  => false,
      :scope  => nil,
      :unique => true
    })

    # Make sure the columns exist
    [options[:from], options[:to]].each do |field|
      unless column_names.include?(field.to_s)
        raise MissingColumnError, "Couldn't find column '#{field}' in '#{table_name}'. Perhaps you have a typo or need to migrate your database?"
      end
    end

    # Define instance methods
    # TODO: automatically uniquify slug?
    class_eval <<-EVAL, __FILE__, __LINE__
      def slugify(force_refresh=false)
        return if self[:#{options[:from]}].nil?

        self[:#{options[:to]}] = if self[:#{options[:to]}].blank? || force_refresh
          # only process from field if slug is blank
          self[:#{options[:from]}].parameterize.to_s
        else
          # always parameterize the slug field, in case the user gives invalid input
          self[:#{options[:to]}].parameterize.to_s
        end
      end

      def slugify!
        slugify(true)
      end
    EVAL

    # Install validations
    validates_presence_of   options[:to]
    validates_uniqueness_of(options[:to], :scope => options[:scope]) if options[:unique]
    validates_format_of     options[:to], :with => /^[-_+a-z0-9]+$/

    # Install filters
    if options[:force]
      before_validation :slugify!
    else
      before_validation :slugify
    end
  end
end

ActiveRecord::Base.extend(Slugify)
