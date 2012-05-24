module ErrorMessagesHelper
  # Render error messages for the given objects. The :message and :header_message options are allowed.
  def error_messages_for(*objects)
    options = objects.extract_options!
    options[:header_message] ||= I18n.t(:"activerecord.errors.header", :default => "Invalid Fields")
    options[:message] ||= I18n.t(:"activerecord.errors.message", :default => "Correct the following errors and try again.")
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      # forced as error but may not abstractly always be the case
      content_tag(:div, :class => "alert alert-block alert-error") do
        list_items = messages.map { |msg| content_tag(:li, msg.html_safe) }
        content_tag(:h2, options[:header_message].html_safe) + content_tag(:p, options[:message].html_safe) + content_tag(:ul, list_items.join.html_safe)
      end
    end
  end

  def display_flash
    partials = String.new
    flash.each do |key, value|
      css_class = key.to_s.eql?('notice') ? 'alert-success' : 'alert-error'
      if value.to_s.present?
       partials << render( :partial => 'shared/flash', :locals => { :css => css_class, :message => value })
      end
    end
    partials.html_safe
  end

  module FormBuilderAdditions
    def error_messages(options = {})
      @template.error_messages_for(@object, options)
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, ErrorMessagesHelper::FormBuilderAdditions)