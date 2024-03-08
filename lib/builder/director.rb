module Builder
  class Director
    attr_accessor :builder

    def initialize(builder:)
      @builder = builder
    end

    def prepare_item_upload_data(pre_upload_id)
      puts "Prepare item upload data at Builder::Director"
    end
  end
end
