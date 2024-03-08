module Factory
  class Item
    include Abstract

    attr_accessor :current_user, :type, :content_type, :builder_director

    def initialize(current_user:)
      @current_user = current_user
    end

    abstract_methods(
      :create_item,
      :create_item_upload,
      :create_item_submit,
      :create_item_check,
    )
  end
end
