module OrdersHelper

  def self.paypal_url(return_url, item_options)
    values = {
        :business => 'sadaf@discretelogix.com',
        :cmd => '_cart',
        :upload => 1,
        :return => return_url,
    }
    values.merge!(item_options)

    # For test transactions use this URL
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end



end
