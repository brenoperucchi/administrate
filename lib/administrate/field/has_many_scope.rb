require "administrate/field/associative.rb"
require "administrate/page/collection"
require "administrate/order"
require "sentient_store.rb"

module Administrate
  module Field
    class HasManyScope < HasMany

      def to_s
        data
      end

      def scoped(data)
        if options.key?(:scoped) 
          if options[:scoped].is_a?(Array)
            data = data.send(:instance_eval, "#{options[:scoped].join(".").to_s}")
          else
            data = data.send(options[:scoped]) if data.respond_to?(options[:scoped])
          end
        end
        # data = data.respond_to?(:not_deleted) ? data.not_deleted : data
        data
      end


      def associated_resource_options(current_store = nil)
        candidate_resources(current_store).map do |resource|
          [display_candidate_resource(resource), resource.send(primary_key)]
        end
      end

      def order_from_params(params)
        Administrate::Order.new(
          params.fetch(:order, sort_by),
          params.fetch(:direction, direction),
        )
      end

      def order
        @order ||= Administrate::Order.new(sort_by, direction)
      end


      def resources(page = 1, order = self.order)
        resources = order.apply(data).page(page).per(limit)
        includes.any? ? resources.includes(*includes) : resources
      end


      def data(current_user=nil)
        data = resource.send(attribute.to_s.pluralize)
        data = scoped(data)
        data
      end

      private

      def includes
        associated_dashboard.collection_includes
      end

      def candidate_resources(current_store =nil)
        if options.key?(:associated) 
          if resource.respond_to?(options[:associated])
            data = current_store.send(attribute.to_s.pluralize)
            # data = resource.send(options[:associated]).send(attribute.to_s.pluralize)
          else
            data = resource.send(attribute.to_s.pluralize)
          end
        elsif options.key?(:includes)
          includes = options.fetch(:includes)
          data = associated_class.includes(*includes).all
        else
          data = associated_class.all
        end
        data = scoped(data)
        order_options = options.key?(:sort_by) ? options[:sort_by].to_s : "id" 
        order_options = options.key?(:direction) ? order_options + options[:direction].to_s : order_options
        data = data.order(order_options) unless order_options.blank?
        data 
      end

      def display_candidate_resource(resource)
        associated_dashboard.display_resource(resource)
      end

    end
  end
end