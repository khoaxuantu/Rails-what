module Builder
  class ItemData
    include Abstract

    abstract_methods(
      :set_pre_upload_record,
      :build_s3_data,
      :build_item_upload_input,
    )
  end
end
