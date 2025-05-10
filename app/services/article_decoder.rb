# app/services/article_decoder.rb

class ArticleDecoder
    def initialize(article_no)
      @article_no = article_no.to_s.gsub(/[^0-9]/, '')
    end
  
    def decode
        prefix = @article_no[0..2]  # ✅ Move this line UP
      
        return default_data("Invalid") if @article_no.length < 7 && prefix != "005"
      
        case prefix
        when "000" then decode_train_tube
        when "001" then decode_led_spot
        when "002" then decode_led_stripe
        when "003" then decode_led_driver
        when "005" then decode_led_treiber
        when "009" then decode_building_tube
        when "011" then decode_led_spots
        else default_data("Unknown")
        end
      rescue => e
        default_data("Error")
      end
  
    def default_data(service)
      {
        service: service,
        type: nil,
        suspension: nil,
        voltage: nil,
        length: nil,
        kelvin: nil,
        cover: nil,
        watt: nil
      }
    end
  
    private
  
    def decode_train_tube
      suspension_code = @article_no[3]
      type_code = @article_no[4]
      voltage_code = @article_no[5]
      length_code = @article_no[6]
      kelvin_code = @article_no[7]
      cover_code = @article_no[8]
  
      type = type_map[type_code]
  
      length = case type
               when "T8" then t8_length_map[length_code]
               when "T5" then t5_length_map[length_code]
               when "T8/T5e" then t8t5e_length_map[length_code]
               else nil
               end
  
      suspension = case type
                   when "T8" then t8_suspension_map[suspension_code]
                   when "T5" then t5_suspension_map[suspension_code]
                   when "T8/T5e" then t8t5e_suspension_map[suspension_code]
                   else nil
                   end
  
      {
        service: "Train Tube",
        type: suspension,
        suspension: type,
        voltage: voltage_map[voltage_code],
        length: length,
        kelvin: kelvin_map[kelvin_code],
        cover: cover_map[cover_code]
      }
    end
  
    def decode_led_spot
        return decode_special_led_spot if special_led_spot?
      
        {
          service: "LED Spot",
          type: led_spot_type[@article_no[3]],
          suspension: led_spot_suspension[@article_no[4]],
          voltage: voltage_map[@article_no[5]],
          kelvin: kelvin_map[@article_no[7]],
          length: led_spot_length[@article_no[8]],
          watt: watt_map[@article_no[6]],
          cover: led_spot_reflector[@article_no[""]]
        }
      end
      def decode_led_spots
        {
          service: "LED Spots",
          type: led_spots_type[@article_no[3]],
          suspension: led_spots_suspension[@article_no[4]],
          voltage: voltages_map[@article_no[5]],
          kelvin: kelvins_map[@article_no[7]],
          length: led_spots_length[@article_no[8]],
          watt: watts_map[@article_no[6]],
          cover: led_spot_reflector[@article_no[""]]
        }
      end
      
      def special_led_spot?
        # e.g., agar 10 digit ya specific 5th character '9' ho
        @article_no.length == 10 && @article_no[4] == '9'
      end
      
      def decode_special_led_spot
        {
          service: "LED Spot - Special",
          type: "Special Type",
          suspension: "Special Suspension",
          voltage: voltage_map[@article_no[5]],
          kelvin: kelvin_map[@article_no[6]],
          length: "Special Length",
          cover: "Special Cover",
          watt: "Special Watt"
        }
      end
  
    def decode_led_stripe
      {
        service: "LED Stripe",
        cover: stripe_cover[@article_no[4]],
        stripe_set: stripe_set[@article_no[3]],
        profile: stripe_profile[@article_no[8]],
        voltage: voltage_map[@article_no[5]],
        length: stripe_length[@article_no[6]],
        kelvin: kelvin_map[@article_no[7]]
      }
    end
  
    def decode_led_driver
      {
        service: "LED Driver",
        output_count: driver_output_count[@article_no[3]],
        output_voltage: driver_output_voltage[@article_no[4]],
        voltage: led_voltage_map[@article_no[5]],
        watt: led_watt_map[@article_no[6]],
        cover: cover_map[@article_no[8]],
        kelvin: kelvin_map[@article_no[7]]
      }
    end
    def decode_led_treiber
        {
          service: "LED Treiber",
          outputs: outputs_count[@article_no[3]],
          wiring: wiring_map[@article_no[5]]
        }
      end
    def decode_building_tube
      {
        service: "Building Tube",
        type: type_map[@article_no[3]],
        suspension: suspension_map[@article_no[4]],
        voltage: voltage_map[@article_no[5]],
        length: length_map[@article_no[6]],
        kelvin: kelvin_map[@article_no[7]],
        cover: cover_map[@article_no[8]],
        watt: watt_map[@article_no[9]]
      }
    end
  
    # Lookup Tables
  
    def type_map
      {"1" => "T8", "2" => "T5", "3" => "T8/T5e"}
    end
  
    def t8_suspension_map
      {"1" => "P-Type", "2" => "V-Type", "3" => "D-Type"}
    end
  
    def t5_suspension_map
      {"1" => "P-Type", "2" => "", "3" => ""}
    end
  
    def t8t5e_suspension_map
      {"1" => "P-Type", "2" => "V-Type", "3" => "D-Type"}
    end
  
    def voltage_map
      {
        "1" => "12VDC", "2" => "24VDC", "3" => "36VDC",
        "4" => "48VDC", "5" => "72VDC", "6" => "110VDC",
        "7" => "230VAC", "8" => "", "9" => "80VDC"
      }
    end
    def voltages_map
        {
          "1" => "12V", "2" => "24V", "3" => "36V",
          "4" => "72V", "5" => "110V", "6" => "230VAC"
        }
      end
    def led_voltage_map
        {
          "0" => "NA", "1" => "12V", "2" => "24V", "3" => "36V",
          "4" => "72V", "5" => "110V"
        }
      end
    
    def t8_length_map
      {
        "1" => "590mm(600mm)", "2" => "895mm(900mm)", "3" => "1200mm",
        "4" => "1500mm", "5" => "438mm", "6" => "",
        "7" => "720mm", "8" => "1080mm", "9" => "970mm"
      }
    end
  
    def t5_length_map
      {
        "1" => "849mm", "2" => "288mm(300)", "3" => "",
        "4" => "560mm", "5" => "517mm", "6" => "549mm",
        "7" => "1149mm", "8" => "1449mm", "9" => ""
      }
    end
  
    def t8t5e_length_map
      {
        "1" => "849mm", "2" => "288mm(300)", "3" => "1080mm",
        "4" => "720mm", "5" => "517mm", "6" => "549mm",
        "7" => "1149mm", "8" => "1449mm", "9" => ""
      }
    end
  
    def kelvin_map
      {
        "0" => "NA", "1" => "1000K", "2" => "2700K", "3" => "3000K",
        "4" => "4000K", "5" => "5000K", "6" => "6500K",
        "7" => "6000K"
      }
    end

    def kelvins_map
        {
          "1" => "1000K", "2" => "2700K", "3" => "3000K",
          "4" => "4000K", "5" => "5000K", "6" => "6000K" 
        }
      end
  
    def cover_map
      {
        "0" => "NA", "1" => "Clear", "2" => "Frosted", "3" => "Clear+Frosted",
        "4" => "Frosted33&Frosted66", "5" => "Frosted50&Frosted50",
        "6" => "Clear50&Clear50", "7" => "Clear50&Frosted50", "8" => "Clear33&Clear66"
      }
    end
  
    def watt_map
      {
        "1" => "1W", "2" => "2W", "3" => "3W", "4" => "4W",
        "5" => "5W"
      }
    end
    def watts_map
        {
          "1" => "3W", "2" => "2W", "3" => "6W", "4" => "5W",
          "5" => "", "6" => "8W (8.5W)", "7" => "15W", "8" => "10W", "9" => "22W"
        }
      end
    def led_watt_map
        {
          "0" => "NA", "1" => "1W", "2" => "3W", "3" => "4W", "4" => "5.5W",
          "5" => "11W", "6" => "18W", "7" => "22W", "8" => "25W"
        }
      end
    
    def led_spot_type
      {"1" => "", "2" => "BA15s", "3" => "BA15d", "4" => "", "5" => "BA22d", "6" => "BA9s", "7" => "BA20d"}
    end

    def led_spots_type
        {"1" => "G-Light"}
      end
    
    def led_spot_suspension
      {"1" => "GU4", "2" => "P21W", "3" => "R10W", "4" => "", "5" => "B22(Bulb)", "6" => "R39", "7" => "B22(candle)", "8" => "MR11" }
    end
    
    def led_spots_suspension
        {"1" => "2G10", "2" => "2G11", "3" => "2G7 (180°)", "4" => "2Gx11", "5" => "G24q-2 (4pins)", "6" => "G24d-2 (2pins)", "7" => "GX24q-2 (4pins)", "8" => "G24q-1 (4pins)", "9" => "2G7 (360°)" }
      end
    
    def led_spot_length
      {"1" => "58mm", "2" => "43mm", "3" => "68mm", "4" => "23mm", "5" => "106mm"}
    end

    def led_spots_length
        {"1" => "215 mm (225mm,211,217)", "2" => "322 mm (320mm)", "3" => "92mm", "4" => "114mm (108mm)", "5" => "147 mm (144mm, 140 )", "6" => "410mm", "7" => "83mm" }
      end
  
    def led_spot_reflector
      {"1" => "Clear", "2" => "Black"}
    end
  
    def stripe_cover
      {"1" => "Clear", "2" => "Frosted"}
    end
  
    def stripe_set
      {"1" => "1x Stripe", "2" => "2x Stripes"}
    end
  
    def stripe_profile
      {"1" => "Standard", "2" => "V-Type 90°" }
    end
  
    def stripe_length
      {
        "1" => "255mm", "2" => "400mm", "3" => "420mm",
        "4" => "300mm", "5" => "517mm", "6" => "549mm",
        "7" => "849mm", "8" => "1149mm", "9" => "1449mm"
      }
    end

    def outputs_count
        { "1" => "1 Tube", "2" => "2 Tube"}
      end

      def wiring_map
        { "1" => "1 mm", "2" => "2 mm"}
      end

    def driver_output_count
      {"0" => "NA", "1" => "One", "2" => "Two"}
    end
  
    def driver_output_voltage
      {"0" => "NA", "1" => "32-39VDC", "2" => "11-15VDC"}
    end
  end
  