class ReportsController < ApplicationController
  def index
    order_ids = params[:order_ids].to_s.split(",")
    @orders = OrderEntry.where(id: order_ids)

    @selected_order_numbers = @orders.pluck(:order_no)

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
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="report.xlsx"'
      end
    end
  end

  private

  def expand_bom(sku_id, order_qty, visited = Set.new)
    return {} if visited.include?(sku_id)

    item = ItemMaster.find_by(sku_id: sku_id)
    return {} unless item

    stock = item.opening_stock || 0
    visited.add(sku_id)

    result = {
      sku_id => {
        sku: sku_id,
        item_name: item.item_name,
        quantity: order_qty,
        stock: stock,
        requirement: stock - order_qty
      }
    }

    bom = BillOfMaterial.joins(:finished_good).find_by(finished_goods: { sku_id: sku_id })
    return result unless bom

    bom.bom_raw_material_items.each do |rm|
      next if rm.quantity.nil?

      rm_sku = rm.item_master.sku_id
      rm_name = rm.item_master.item_name
      rm_stock = rm.item_master.opening_stock || 0

      rm_total_qty = rm.quantity * order_qty

      if BillOfMaterial.joins(:finished_good).exists?(finished_goods: { sku_id: rm_sku })
        # Recursive call for nested FG
        child_result = expand_bom(rm_sku, rm_total_qty, visited.dup)

        child_result.each do |sku, data|
          if result[sku]
            result[sku][:quantity] += data[:quantity]
            result[sku][:requirement] = result[sku][:stock] - result[sku][:quantity]
          else
            result[sku] = data
          end
        end
      else
        # Raw material accumulation
        if result[rm_sku]
          result[rm_sku][:quantity] += rm_total_qty
          result[rm_sku][:requirement] = result[rm_sku][:stock] - result[rm_sku][:quantity]
        else
          result[rm_sku] = {
            sku: rm_sku,
            item_name: rm_name,
            quantity: rm_total_qty,
            stock: rm_stock,
            requirement: rm_stock - rm_total_qty
          }
        end
      end
    end

    result
  end
end
