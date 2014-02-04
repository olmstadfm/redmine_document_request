module DocumentRequestPlugin
  module IssueCategoryPatch

    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        validator = IssueCategory._validators[:name].find{|v| v.class == ActiveModel::Validations::LengthValidator}
        validator.instance_eval{ @options = {:maximum=>150} }

      end

    end

    module ClassMethods
    end

    module InstanceMethods
    end

  end
end
