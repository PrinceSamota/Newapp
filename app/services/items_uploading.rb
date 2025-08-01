class ItemsUploading
  def initialize(file)
    @file = file
  end

  def upload
    xlsx = Roo::Spreadsheet.open(@file)
    items_sheet = xlsx.sheet('itemMaster')
    item_master_upload(items_sheet)
    bom_sheet = xlsx.sheet('BOM')
    bom_upload(bom_sheet)
  end

  private

  def lookup_id(klass, name)
    return nil if name.blank?
    klass.find_or_create_by(name: name)&.id
  end


  def to_boolean(value)
    return false if value.nil?
    value.to_s.strip.downcase == 'yes' || value.to_s.strip.downcase == 'true'
  end

  def item_master_upload(items_sheet)
    header = items_sheet.row(1).map(&:to_s).map(&:strip).map(&:downcase)
    error_list = []
    indices = {
      item_name: header.find_index("item_name"),
      opening_stock: header.find_index("opening_stock"),
      purchase_price: header.find_index("purchase_price"),
      sale_price: header.find_index("sale_price"),
      is_bom: header.find_index("is_bom"),
      sku: header.find_index("sku"),
      article_number: header.find_index("article_number"),
      minimum_stock_level: header.find_index("minimum_stock_level"),
      category: header.find_index("category"),
      measurement: header.find_index("measurement"),
      fuse_type: header.find_index("fuse_type"),
      loop: header.find_index("loop"),
      item_type: header.find_index("item_type"),
      profile: header.find_index("profile"),
      wattage: header.find_index("wattage"),
      voltage: header.find_index("voltage"),
      length: header.find_index("length"),
      cct: header.find_index("cct"),
      cover_type: header.find_index("cover_type"),
      extra: header.find_index("extra"),
      minimum_stock_level: header.find_index("minimum_stock_level")
    }
    # Stream each row from row 2 (index 1)
    items_sheet.each_row_streaming(offset: 1) do |row|
      item_attributes = {
        item_name:              row[indices[:item_name]]&.value,
        opening_stock:          row[indices[:opening_stock]]&.value,
        purchase_price:         row[indices[:purchase_price]]&.value,
        sale_price:             row[indices[:sale_price]]&.value,
        is_bom:                 to_boolean(row[indices[:is_bom]]&.value),
        sku_id:                 row[indices[:sku]]&.value,
        article_number:         row[indices[:article_number]]&.value,
        minimum_stock_level:    row[indices[:minimum_stock_level]]&.value,
        category_id:            lookup_id(Category, row[indices[:category]]&.value),
        measurement_id:         lookup_id(Measurement, row[indices[:measurement]]&.value),
        fuse_type_id:           lookup_id(FuseType, row[indices[:fuse_type]]&.value),
        loop_id:                lookup_id(Loop, row[indices[:loop]]&.value),
        item_type_id:           lookup_id(ItemType, row[indices[:item_type]]&.value),
        profile_id:             lookup_id(Profile, row[indices[:profile]]&.value),
        wattage_id:             lookup_id(Wattage, row[indices[:wattage]]&.value),
        voltage_id:             lookup_id(Voltage, row[indices[:voltage]]&.value),
        length_id:              lookup_id(Length, row[indices[:length]]&.value),
        cct_id:                 lookup_id(Cct, row[indices[:cct]]&.value),
        cover_type_id:          lookup_id(CoverType, row[indices[:cover_type]]&.value),
        extra_id:               lookup_id(Extra, row[indices[:extra]]&.value),
        minimum_stock_level:    row[indices[:minimum_stock_level]]&.value || 0
      }

      item = ItemMaster.new(item_attributes)
      if item.save
        puts "Saved item: #{item.item_name}"
      else
        error_list << "#{item.sku_id} - Errors: #{item.errors.full_messages.join(', ')}"
        puts "Failed to save item: #{item.item_name} - Errors: #{item.errors.full_messages.join(', ')}"
      end
    end
    puts "**************TOTAL #{error_list.count}*******************#{error_list}************************"
  end

  def bom_upload(bom_sheet)
    header = bom_sheet.row(1).map(&:to_s).map(&:strip).map(&:downcase)
    error_list = []

    indices = {
      bom_number: header.find_index("bom_id"),
      fg_sku:     header.find_index("fg_sku"),
      rm_sku:     header.find_index("rm_sku"),
      quantity:   header.find_index("quantity"),
    }

    bom_sheet.each_row_streaming(offset: 1) do |row|
      fg_sku_value = row[indices[:fg_sku]]&.value
      rm_sku_value = row[indices[:rm_sku]]&.value
      quantity     = row[indices[:quantity]]&.value
      bom_number   = row[indices[:bom_number]]&.value

      fg_item_master = ItemMaster.find_by(sku_id: fg_sku_value)
      rm_item_master = ItemMaster.find_by(sku_id: rm_sku_value)

      if fg_item_master && rm_item_master
        # Create or find BOM
        bom = BillOfMaterial.find_or_initialize_by(bom_number: bom_number)
        bom.name = fg_item_master.item_name

        unless bom.save
          error_list << "BOM Error [#{bom_number}]: #{bom.errors.full_messages.join(', ')}"
          next
        end

        # Create or find FG
        fg = FinishedGood.find_or_initialize_by(
          bill_of_material_id: bom.id,
          sku_id: fg_item_master.sku_id
        )
        fg.assign_attributes(
          item_name: fg_item_master.item_name,
          quantity: 1,
          unit: fg_item_master.measurement.name
        )

        unless fg.save
          error_list << "FinishedGood Error [#{fg_sku_value}]: #{fg.errors.full_messages.join(', ')}"
          next
        end

        # Create or find RM
        rm = BomRawMaterialItem.find_or_initialize_by(
          bill_of_material_id: bom.id,
          sku_id: rm_item_master.sku_id,
          item_master_id: rm_item_master.id
        )
        rm.assign_attributes(
          item_name: rm_item_master.item_name,
          quantity: quantity,
          unit: rm_item_master.measurement.name
        )

        unless rm.save
          error_list << "RawMaterial Error [#{rm_sku_value}]: #{rm.errors.full_messages.join(', ')}"
        end
      else
        error_list << "Missing ItemMaster: FG[#{fg_sku_value}] or RM[#{rm_sku_value}] not found"
      end
    end

    puts "************** TOTAL ERRORS: #{error_list.count} **************"
    puts error_list.join("\n")
  end


end
