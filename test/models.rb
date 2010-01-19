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

# missing columns
class Failure < ActiveRecord::Base
end
