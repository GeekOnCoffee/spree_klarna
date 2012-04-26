class Spree::Gateway::Klarna < Spree::Gateway
  preference :store_id, :string
  preference :store_secret, :string

  attr_accessible :preferred_store_id, :preferred_store_secret
  
  def provider_class
    SpreeKlarna::Client 
  end

  def payment_profiles_supported?
    false
  end

  def authorize(amount, creditcard, gateway_options)
    options = {}
    @order = Spree::Order.find_by_number(gateway_options[:order_id])
      @client = SpreeKlarna::Client.new(self.preferred_store_id, Base64.encode64(Digest::MD5.digest(self.preferred_store_secret)).chomp) 
      (ponum, invoiceStatus) = 1
      puts @client.call2("add_invoice","4.1","ruby/xmlrpc","410321-9202",1 ,self.preferred_store_id,@order.number, @order.id.to_s,"",{:email => @order.email, :telno => @order.bill_address.phone, :cellno => "", :fname => @order.bill_address.firstname, :lname => @order.bill_address.lastname, :company => @order.bill_address.company || "" ,:careof => "", :street => @order.bill_address.address1, :house_number => "1", :house_extension => "", :zip => @order.bill_address.zipcode, :city => @order.bill_address.city,:country => 209},{:email => @order.email, :telno => @order.ship_address.phone, :cellno => "", :fname => @order.ship_address.firstname, :lname => @order.ship_address.lastname, :company => @order.ship_address.company || "" ,:careof => "", :street => @order.ship_address.address1, :house_number => "1", :house_extension => "", :zip => @order.ship_address.zipcode, :city => @order.ship_address.city,:country => 209},"127.0.0.1",0,0,209,138,2130, get_secret(self.preferred_store_id, @order.line_items),2,-1,[{:goods => {:artno => "1", :title => "mytitle",:price => 890, :vat => 13.0, :flags => 32, },:qty => 1}],"comment",{:delay_adjust => 1},[],[],[],{:dev_id_1 => "9913127001315810399382165327830000001715"},[])
      status = true if [1,2].include?(invoiceStatus)
      return ActiveMerchant::Billing::Response.new(status, ponum, {}, options) 
  end
  
  def get_secret(secret=self.preferred_store_id, line_items)
    string = secret
    line_items.each do |line_item|
      string += line_item.variant.name + ":"
    end
    return string
  end
end
