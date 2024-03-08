module Builder
  class PhotoData < ItemData
    def initialize
      
    end

    def set_pre_upload_record
      puts "Go to set_pre_upload_record"
    end

    def build_s3_data
      puts "Build S3 data"
    end

    def build_item_upload_input
      puts "Build item upload input"
    end
  end
end
