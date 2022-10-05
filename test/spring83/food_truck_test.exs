defmodule Spring83.FoodTruckTest do
  use ExUnit.Case

  alias Spring83.FoodTruck

  describe "from_json" do
    test "returns a FoodTruck" do
      assert FoodTruck.from_json(%{
               "applicant" => "some applicant",
               "fooditems" => "pizza!",
               "junk" => "should be dropped",
               "locationdescription" => "out there",
               "latitude" => "37.89",
               "longitude" => "0",
               "objectid" => "1234",
               "status" => "Deadly - stay away!"
             }) == %FoodTruck{
               applicant: "some applicant",
               fooditems: "pizza!",
               id: nil,
               inserted_at: nil,
               latitude: 37.89,
               locationdescription: "out there",
               longitude: 0.0,
               objectid: "1234",
               status: "Deadly - stay away!",
               updated_at: nil
             }
    end
  end

  describe "vendor_name" do
    test "removes LLC and Inc." do
      assert FoodTruck.vendor_name(%FoodTruck{applicant: "MOMO INNOVATION LLC"}) ==
               "MOMO INNOVATION"

      assert FoodTruck.vendor_name(%FoodTruck{applicant: "Off the Grid Services, Inc."}) ==
               "Off the Grid Services"
    end

    test "removes everything before DBA or dba or a slash" do
      assert FoodTruck.vendor_name(%FoodTruck{
               applicant: "Huge Conglomerate DBA Your Friendly Neighbor"
             }) == "Your Friendly Neighbor"

      assert FoodTruck.vendor_name(%FoodTruck{applicant: "EvilCorp / Mom & Apple Pie"}) ==
               "Mom & Apple Pie"

      assert FoodTruck.vendor_name(%FoodTruck{applicant: "Datam SF LLC dba Anzu To You"}) ==
               "Anzu To You"
    end
  end

  describe "offerings" do
    test "formats the name and foods as ugly HTML that looks pretty on the page" do
      assert FoodTruck.offerings(%FoodTruck{
               applicant: "Datam SF LLC dba Anzu To You",
               fooditems: "pizza ; tacos: ramen; pecans"
             }) ==
               "<h3>Anzu To You</h3>pizza <br /> tacos<br /> ramen<br /> pecans"
    end
  end

  describe "maybe_japanese?" do
    test "returns true if it mentions Japan" do
      assert FoodTruck.maybe_japanese?(%FoodTruck{fooditems: "food that mentions jApaN!"})
    end

    test "returns true if it mentions a food that includes sashimi" do
      assert FoodTruck.maybe_japanese?(%FoodTruck{
               fooditems: "a poke bowl Japanese (and also Hawaiian)"
             })
    end

    test "returns true for octopus (tako)" do
      assert FoodTruck.maybe_japanese?(%FoodTruck{fooditems: "tako is from that island!"})
    end

    test "returns false for other foods" do
      refute FoodTruck.maybe_japanese?(%FoodTruck{fooditems: "tacos are not from there"})
    end
  end

  describe "plausible_location?" do
    test "returns true iff latitude and longitude are non-zero" do
      refute FoodTruck.plausible_location?(%FoodTruck{latitude: 0.0})
      refute FoodTruck.plausible_location?(%FoodTruck{longitude: 0.0})
      assert FoodTruck.plausible_location?(%FoodTruck{latitude: 13.7, longitude: -120.93})
    end
  end

  describe "approved?" do
    test "does the right thing" do
      refute FoodTruck.approved?(%FoodTruck{status: "norovirus"})
      assert FoodTruck.approved?(%FoodTruck{status: "APPROVED"})
    end
  end
end
