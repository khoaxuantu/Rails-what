module Factory
  class Photo < Item
    def initialize(current_user:)
      super(current_user: current_user)
      @type = 'Photo'
      @content_type = 0
      @builder_director = Builder::Director.new(builder: Builder::PhotoData.new)
    end

    def create_item_upload(pre_upload_id)
      puts "Create item upload at Factory::Photo"
      data = @builder_director.prepare_item_upload_data pre_upload_id
      puts data
    end
  end
end
