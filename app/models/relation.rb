class Relation
  class_attribute :lon1, :lat1, :lon2, :lat2

  def initialize(lat1, lon1, lat2, lon2)
    self.lon1 = lon1
    self.lon2 = lon2
    self.lat1 = lat1
    self.lat2 = lat2
  end

  def get_distance(user)
    if self.user == user
      self.partner
    else
      self.user
    end
  end

  def get_distance
    theta = self.lon1 - self.lon2
    dist = Math.sin(deg2rad(self.lat1)) * Math.sin(deg2rad(self.lat2)) +  Math.cos(deg2rad(self.lat1)) * Math.cos(deg2rad(self.lat2)) * Math.cos(deg2rad(theta))
    dist = Math.acos(dist)
    dist = rad2deg(dist)
    miles = dist * 60 * 1.1515
    return (miles * 1.609344)
  end

  def deg2rad(value)
    rad_value = value * Math::PI / 180
    return rad_value
  end
  def rad2deg(value)
    deg_value = value * 180 / Math::PI
    return deg_value
  end

end
