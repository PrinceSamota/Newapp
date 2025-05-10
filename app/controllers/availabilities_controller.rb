class AvailabilitiesController < ApplicationController
        before_action :set_shop_owner
      
        def new
          @variables_by_category = {
            "Type" => ['P-Type', 'V-Type', 'D-Type'],
            "Suspension" => ['T5', 'T6/T5e', 'T6/T5e ECO', 'T8', 'T8 ECO', 'T8/T5e', 'T8/T5e ECO',],
            "Voltage" => ['12VDC', '24VDC', '36VDC', '48VDC', '72VDC', '80VDC', '110VDC', '230VAC', '220VDC', '85VAC', '275VAC', '39VDC', '15VDC'],
            "Length" => ['288mm', '300mm', '320mm', '400mm', '420mm', '438mm', '517mm', '549mm', '560mm', '590mm', '600mm', '720mm', '849mm', '895mm', '900mm', '970mm', '1080mm', '1149mm', '1200mm', '1449mm', '1500mm', '108mm', '144mm', '225mm', '255mm'],
            "Kelvin" => ['1000K', '2700K', '3000K', '4000K', '5000K', '6000K', '6500K'],
            "Cover" => ['Clear', 'Frosted', 'Clear33&Frosted66', 'Clear50&Frosted50', 'Clear50&Clear50', 'Clear33&Clear66', 'Frosted33&Frosted66', 'Frosted50&Frosted50'],
            "Wattage" => ['1W', '2W', '3W', '4W', '5W', '6W', '8W', '8,5W', '10W', '11W', '15W', '18W', '22W', '24W', '25W', '28W', '35W']
          }
        end
      
        def create
          params[:availability]&.each do |category, items|
            items.each do |variable, value|
              next if value.blank?
        
              availability = @shop_owner.availabilities.find_or_initialize_by(
                category: category,
                variable: variable
              )
        
              availability.value = value
              availability.save!
            end
          end
        
          redirect_to availabilities_path, notice: "Stock saved successfully."
        end
      
        def index
          @availabilities = @shop_owner.availabilities.group_by(&:category)
        end
      
        private
      
        def set_shop_owner
          @shop_owner = current_user # Or current_shop_owner if using Devise
        end
      end

