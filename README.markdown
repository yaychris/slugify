Slugify
=======

Slugify is a Rails plugin that automatically converts an attribute into a pretty URL slug and assigns it to another attribute. Conversion happens in a `before_validation` filter or by manually calling the `#slugify` or `#slugify!` instance methods.

Internally, it uses ActiveSupport's `#parameterize` method and is multi-byte safe.


Usage
-----

By default, slugify generates the slug from the `:title` attribute and assigns it to the `:slug` attribute:

    class Page < ActiveRecord::Base
      slugify
    end

    @page = Page.new :title => "Yay Hooray"
    @page.slugify
    @page.slug        # -> "yay-hooray"

Both fields can be overridden:

    class User < ActiveRecord::Base
      slugify :name, :to => :permalink
    end

    @user = User.new :name => "Fox Mulder"
    @user.slugify
    @user.permalink   # -> "fox-mulder"

Slugify will only assign a slug if the `:to` attribute is blank. This is to prevent all the URLs from breaking every time the user changes a title. Continuing from the example above:

    @user.name = "Dana Scully"
    @user.slugify
    @user.permalink   # -> "fox-mulder"

To override, use the `#slugify!` instance method:

    @user.name = "Dana Scully"
    @user.slugify!
    @user.permalink   # -> "dana-scully"

or set the option in the DSL:

    class Product < ActiveRecord::Base
      slugify :title, :to => :permalink, :force => true
    end

Slugify will automatically validate for presence, format, and uniqueness. It's easy to scope the uniqueness constraint:

    class Page < ActiveRecord::Base
      slugify :title, :scope => :section_id
    end

or turn the constrain off:

    class BlogPost < ActiveRecord::Base
      slugify :title, :unique => false
    end

Include the ID
--------------

To include the id in the slug, do it in the `#to_param` method:

    class Book < ActiveRecord::Base
      slugify

      def to_param
        "#{id}-#{slug}"
      end
    end

_Bonus!_ If you include the id first, you can pass the whole slug into `#find` and it'll Just Work™:

    Book.create(:title => "The Stand")
    @book = Book.find("1-the-stand")
    @book.title     # -> "The Stand"


License
-------

                DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
                        Version 2, December 2004 

     Copyright (C) 2010 Chris Jones
     Everyone is permitted to copy and distribute verbatim or modified 
     copies of this license document, and changing it is allowed as long 
     as the name is changed. 

                DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
       TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

      0. You just DO WHAT THE FUCK YOU WANT TO. 
