module Merb
  module GlobalHelpers
    
    def textile_to_html(content)
      RedCloth.new(content).to_html
    end
    
    # TODO: merb is supposed ot have a built in lib for this. Use it.
    def render_relative_date(date)
      date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
      days = (date - Date.today).to_i

      return 'today'     if days >= 0 and days < 1
      return 'tomorrow'  if days >= 1 and days < 2
      return 'yesterday' if days >= -1 and days < 0

      return "in #{days} days"      if days.abs < 60 and days > 0
      return "#{days.abs} days ago" if days.abs < 60 and days < 0

      return date.strftime('%A, %B %e') if days.abs < 182
      return date.strftime('%A, %B %e, %Y')
    end

    def notifications
      notifications = session[:notifications]
      session[:notifications] = nil
      notifications
    end
    
    def get_timezones
      TZInfo::Timezone.all.collect { |tz| tz.name }
    end
    
    def render_relative_published_at(article)
      article.published_at.nil? ? "Not yet" : render_relative_date(TZInfo::Timezone.get(logged_in? ? self.current_user.time_zone : article.user.time_zone).utc_to_local(article.published_at))
    end
    
    def render_about_text
      unless @settings.nil? || @settings.about.blank?
        markup = <<-MARKUP
        <div class="sidebar-node">
          <h3>About</h3>
          <p>#{textile_to_html(@settings.about)}</p>
        </div>
        MARKUP
      end
      markup
    end
    
    def year_url(year)
      url(:year, {:year => year})
    end
    
    def month_url(year, month)
      url(:month, {:year => year, :month => Padding::pad_single_digit(month)})
    end
    
    def day_url(year, month, day)
      url(:day, {:year => year, :month => Padding::pad_single_digit(month), :day => Padding::pad_single_digit(day)})
    end

    ##
    # This returns all items, including those provided by plugins
    def menu_items
      items = []
      Hooks::Menu.menu_items.each { |item| items << item }
      items << {:text => "Dashboard", :url => url(:admin_dashboard)}
      items << {:text => "Articles", :url => url(:admin_articles)}
      items << {:text => "Plugins", :url => url(:admin_plugins)}
      items << {:text => "Settings", :url => url(:admin_configurations)}
      items << {:text => "Users", :url => url(:admin_users)}
      if self.current_user == :false
        items << {:text => "Login", :url => url(:login)}
      else
        items << {:text => "Logout", :url => url(:logout)}
      end
      items
    end
    
    def render_link_dot(index, collection_size)
      "&nbsp;•" unless index == collection_size
    end
    
    ##
    # This renders all plugin views for the specified hook
    def render_plugin_views(name, options = {})
      output = ""
      Hooks::View.plugin_views.each do |view|
        if view[:name] == name
          _template_root = File.join(view[:plugin].path, "views")
          template_location = _template_root / _template_location("_#{view[:partial]}", content_type, view[:name])
          template_method = Merb::Template.template_for(template_location)
          output << send(template_method, options)
        end
      end
      output
    end
  end
end