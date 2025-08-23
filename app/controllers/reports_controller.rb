class ReportsController < ApplicationController
  def index
    order_ids = params[:order_ids].to_s.split(",")
    @orders = OrderEntry.where(id: order_ids)
  
    # collect order numbers for showing in view
    @selected_order_numbers = @orders.pluck(:order_number) rescue @orders.pluck(:id)
  
    sku_hash = {}
  
    @orders.each do |order|
      sku_data = expand_bom(order.sku_number, order.qty)
  
      sku_data.values.each do |row|
        sku = row[:sku]
        if sku_hash[sku]
          sku_hash[sku][:quantity] += row[:quantity]
          sku_hash[sku][:requirement] = sku_hash[sku][:stock] - sku_hash[sku][:quantity]
        else
          sku_hash[sku] = row
        end
      end
    end
  
    @report_data = sku_hash.values
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="report.xlsx"'
      }
    end
  end
  
  private
  def expand_bom(sku_id, order_qty, visited = Set.new, parent_bom_qty = 1, top_level: true)
    return {} if visited.include?(sku_id)
  
    item = ItemMaster.find_by(sku_id: sku_id)
    return {} unless item
  
    stock = item.opening_stock || 0
    rm_final_qty = top_level ? 0 : parent_bom_qty * order_qty
  
    result = {
      sku_id => {
        sku: sku_id,
        quantity: rm_final_qty,
        stock: stock,
        requirement: stock - rm_final_qty,
        bom_defined_qty: parent_bom_qty
      }
    }
  
    visited.add(sku_id)
  
    bom = BillOfMaterial.joins(:finished_good).find_by(finished_goods: { sku_id: sku_id })
    return result unless bom
  
    fg_qty = bom.finished_good.quantity.presence || 1
    fg_final_qty = fg_qty * order_qty
  
    result[sku_id][:quantity] += fg_final_qty
    result[sku_id][:requirement] = result[sku_id][:stock] - result[sku_id][:quantity]
  
    bom.bom_raw_material_items.each do |rm|
      next if rm.quantity.nil?
      rm_sku = rm.item_master.sku_id
      rm_qty = rm.quantity * order_qty
  
      if BillOfMaterial.joins(:finished_good).exists?(finished_goods: { sku_id: rm_sku })
        child_result = expand_bom(
          rm_sku,
          order_qty,
          visited.dup,
          rm.quantity,
          top_level: false
        )
  
        child_result.each do |sku, data|
          if result[sku]
            result[sku][:quantity] += data[:quantity]
            result[sku][:requirement] = result[sku][:stock] - result[sku][:quantity]
          else
            result[sku] = data
          end
        end
      else
        if result[rm_sku]
          result[rm_sku][:quantity] += rm_qty
          result[rm_sku][:requirement] = result[rm_sku][:stock] - result[rm_sku][:quantity]
        else
          result[rm_sku] = {
            sku: rm_sku,
            quantity: rm_qty,
            stock: rm.item_master.opening_stock || 0,
            requirement: (rm.item_master.opening_stock || 0) - rm_qty,
            bom_defined_qty: rm.quantity
          }
        end
      end
    end
  
    result
  end
end
