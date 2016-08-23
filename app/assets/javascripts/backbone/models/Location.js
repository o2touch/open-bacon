App.Modelss.Location = Backbone.RelationalModel.extend({

  equals: function(other) {
    return (other &&
      this.get("title") == other.get("title") &&
      this.get("address") == other.get("address") &&
      this.get("lat") == other.get("lat") &&
      this.get("lng") == other.get("lng"));
  },

  isEquivalentTo: function(location) {
    var threshold = 0.00001,
      latDiff = Math.abs(this.get('lat') - location.get("lat")),
      lngDiff = Math.abs(this.get('lng') - location.get("lng"));
    return (latDiff < threshold && lngDiff < threshold);
  },

  setFromString: function(s) {
    s = s.trim();
    this.set({
      id: null,
      title: s,
      address: s,
      lat: null,
      lng: null
    });
  },

  // valid location if has title and either address or latlng
  // left this here for backwards compatibility
  isValidWeak: function() {
    return (this.get("title") && this.hasExactLocation());
  },

  // true validation: must have lat lng
  isValid: function() {
    return (this.get("title") && this.hasLatLng());
  },

  // if we have an address or a latlng
  hasExactLocation: function() {
    return (this.get("address") || this.hasLatLng());
  },

  hasLatLng: function() {
    return (this.get("lat") && this.get("lng"));
  },

  getQueryString: function() {
    if (this.hasLatLng()) {
      return this.get("lat") + "," + this.get("lng");
    } else if (this.get("address")) {
      return this.get("address");
    } else {
      return this.get("title")
    }
  },

  getLatLng: function() {
    return this.get("lat") + "," + this.get("lng");
  },

  // turn a lat-lng string e.g. "-120.283746,-30.23976436"
  // into a safe ID name e.g. "ah120d283746ch30d23976436"
  getLocationId: function() {
    var latlng = this.get("lat") + "c" + this.get("lng");
    return "a" + latlng.replace(/\./g, "d").replace(/-/g, "h");
  },

});