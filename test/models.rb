ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
ActiveRecord::Schema.define do
  create_table :pages do |t|
    t.string :title
    t.string :slug
  end

  create_table :users do |t|
    t.string :name
    t.string :slug
  end

  create_table :uploads do |t|
    t.string :file_name
    t.string :short_name
  end

  create_table :posts do |t|
    t.string :title
    t.string :slug
  end

  create_table :scoped_pages do |t|
    t.string  :title
    t.string  :slug
    t.integer :section_id
  end

  create_table :sections do |t|
    t.string :title
    t.string :slug
  end

  create_table :blog_posts do |t|
    t.string :title
    t.string :slug
  end

  create_table :failures do |t|
    t.string :valid_from
    t.string :valid_to
  end
end


# default options
class Page < ActiveRecord::Base
  slugify
end

# from field specified
class User < ActiveRecord::Base
  slugify :name
end

# from and to fields specified
class Upload < ActiveRecord::Base
  slugify :file_name, :to => :short_name
end

# force
class Post < ActiveRecord::Base
  slugify :title, :force => true
end

# scope
class ScopedPage < ActiveRecord::Base
  slugify :title, :scope => :section_id
  belongs_to :section
end

class Section < ActiveRecord::Base
  has_many :pages, :class_name => "ScopedPage"
end

# turn off unique
class BlogPost < ActiveRecord::Base
  slugify :title, :unique => false
end

# missing columns
class Failure < ActiveRecord::Base
end
