module ValidatesBySchema
  autoload :ValidationOption, 'validates_by_schema/validation_option'

  extend ActiveSupport::Concern

  module ClassMethods
    def validates_by_schema(options = {})
      return unless table_exists?

      columns = schema_validateable_columns

      # Allow user to specify :only or :except options
      { only: :select!, except: :reject! }.each do |k, v|
        if options[k]
          attrs = Array(options[k]).collect(&:to_s)
          columns.send(v) { |c| attrs.include?(c.name) }
        end
      end

      columns.each do |c|
        vo = ValidationOption.new(c).to_hash
        validates c.name, vo if vo.present?
      end
    end

    def schema_validateable_columns
      # Don't auto validate primary keys or timestamps
      columns.reject do |c|
        c.name == primary_key.to_s || %w(updated_at created_at).include?(c.name)
      end
    end
  end
end

ActiveSupport.on_load :active_record do
  include ValidatesBySchema
end
