# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def route_s(string, transport_type)
    case transport_type
    when /Bus/i
      "Bus #{string}"
    else
      string
    end

  end

end
