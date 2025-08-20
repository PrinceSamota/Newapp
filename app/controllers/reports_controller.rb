class ReportsController < ApplicationController
    def index
      order_ids = params[:order_ids].to_s.split(",")
      @orders = OrderEntry.where(id: order_ids)
  
      @report_data = []
  
      @orders.each do |order|
        fg_item = ItemMaster.find_by(sku_id: order.sku_number)
  
        if fg_item
          bom_as_fg = BillOfMaterial.joins(:finished_good)
                                    .find_by(finished_goods: { sku_id: fg_item.sku_id })
  
          if bom_as_fg
            fg_qty = (bom_as_fg.try(:quantity) || 1) * order.qty
            stock = fg_item.opening_stock || "-"
            requirement =  stock - fg_qty
            @report_data << {
              order_no: order.order_no,
              fg_sku: order.sku_number,
              rm_sku: "-",
              quantity: fg_qty,
              stock: fg_item.opening_stock || "-",
              requirement: requirement
            }
  
            bom_as_fg.bom_raw_material_items.each do |rm_item|
              rm_sku = rm_item.item_master.sku_id
              rm_qty = rm_item.quantity * order.qty 
              rm_stock = rm_item.item_master.opening_stock || "-"
              requirement = rm_stock - rm_qty

              @report_data << {
                order_no: order.order_no,
                fg_sku: "-",   
                rm_sku: rm_sku,
                quantity: rm_qty,
              stock: rm_stock,
              requirement:  requirement
            
              }
            end
  
          else
            bom_as_rm = BomRawMaterialItem.joins(:bill_of_material, :item_master)
                                          .find_by(item_masters: { sku_id: fg_item.sku_id })
  
            if bom_as_rm
                rm_qty = bom_as_rm.quantity * order.qty 
                stock = fg_item.opening_stock || "-"
                requirement = stock - rm_qty

              @report_data << {
                order_no: order.order_no,
                fg_sku: "-", 
                rm_sku: fg_item.sku_id,
                quantity: rm_qty,
                stock: stock,
                requirement: requirement
                
              }
            else
                stock = fg_item.opening_stock || "-"
                requirement = stock - qty 
              @report_data << {
                order_no: order.order_no,
                fg_sku: order.sku_number,
                rm_sku: "-",
                quantity: rm_qty,
                stock: stock,
                requirement: requirement
              }
            end
          end
        end
      end
    end
  end
  