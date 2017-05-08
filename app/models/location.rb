class Location
  def self.get_distance(lat1, lon1, lat2, lon2)
    if lat1 && lon1 && lat2 && lon2
      theta = lon1 - lon2
      dist = Math.sin(self.deg2rad(lat1)) * Math.sin(self.deg2rad(lat2)) +  Math.cos(self.deg2rad(lat1)) * Math.cos(self.deg2rad(lat2)) * Math.cos(self.deg2rad(theta))
      dist = Math.acos(dist)
      dist = self.rad2deg(dist)
      miles = dist * 60 * 1.1515
      return (miles * 1.609344)
    else
      return 0
    end
  end

  def self.deg2rad(value)
    rad_value = value * Math::PI / 180
    return rad_value
  end
  def self.rad2deg(value)
    deg_value = value * 180 / Math::PI
    return deg_value
  end
end
