module Administrate
  module Field
		class BelongsToField < Administrate::Field::BelongsTo
			include SentientStore

			def scoped
			  options.key?(:scoped) ? options[:scoped] : nil
			end

			def associated_resource_options(current_user =nil)
			  candidate_resources(current_user).map do |resource|
			    [display_candidate_resource(resource), resource.send(primary_key)]
			  end
			end

			private 

			def candidate_resources(current_user=nil)
				if current_user
					if options.key?(:associated) and current_user.respond_to?(options[:associated])
						collection = current_user.send(options[:associated]).send(associated_class.name.to_underscore.pluralize.downcase.to_sym)
						collection = collection.send(scoped) if scoped
						collection
					else
						# scope = options[:scope] ? options[:scope].call : current_store_field.send(associated_class.name.pluralize.downcase.to_sym).send(scoped)
						if resource.respond_to?(associated_class.name.downcase.to_sym)
							resource.send(associated_class.name.downcase.to_sym).send(scoped)
						else					
							resource.send(associated_class.name.pluralize.downcase.to_sym).send(scoped)
						end
				  end
				end
			  # order = options.delete(:order)
			  # order ? scope.reorder(order) : scope
			end

			def display_candidate_resource(resource)
			  associated_dashboard.display_resource(resource)
			end

			# def associated_dashboard
			# 	if options.key?(:dashboard) and options[:dashboard].try(:downcase).try(:to_s) == "control"
			# 		if "Control::#{associated_class_name}Dashboard".is_a_defined_class?
			# 			return "Control::#{associated_class_name}Dashboard".constantize.new
			# 		end
			# 	end
			# 	super
			# end

		end
	end
end