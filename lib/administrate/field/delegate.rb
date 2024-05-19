require_relative "associative"

module Administrate
  module Field
    class Delegate < BelongsTo
    	def self.foreign_key_for(resource_class, attr)
    	  # reflection(resource_class, attr).foreign_key
    	  nil
    	end


      def associated_class_name
        if option_given?(:class_name)
          deprecated_option(:class_name).classify.constantize
        else
          self.class.associated_class_name(
            resource.class,
            attribute,
          )
        end
      end

     	def associated_resource_options
        candidate_resources.map do |resource|
          [display_candidate_resource(resource), resource.send(primary_key)]
        end
      end

      def selected_option
        data && data.send(primary_key)
      end

      def include_blank_option
        options.fetch(:include_blank, true)
      end

      private

      def candidate_resources
        scope = options[:scope] ? options[:scope].call : associated_class.all

        order = options.delete(:order)
        order ? scope.reorder(order) : scope
      end

      def display_candidate_resource(resource)
        associated_dashboard.display_resource(resource)
      end
    end
  end
end
