function Dispatcher (tree_id, map_id) {
  self           = this,
  this.tree      = null,
  this.map       = null,
  this.markers   = {},
  this._data     = null, 
  this._infoWindow = new google.maps.InfoWindow({ content : "" }),
  this._tree_elem  = $("#" + tree_id),
  this._map_elem = $("#" + map_id),
  this._timeout  = null,
  this.search_marker = null,
  
  this.init = function(map_id){
    $(window).resize(self.adjustMapHeight).resize();
    
    self.map = new google.maps.Map( document.getElementById(map_id), {
      zoom      : 11,
      mapTypeId : google.maps.MapTypeId.ROADMAP, 
      center    : new google.maps.LatLng(45.5234515, -122.6762071)
    });
    
    google.maps.event.addListener(self.map, "click", function(){
      self._infoWindow.close();
    });
    
    self.initTree();
    
    self._resetRefreshTimer();
  },
  
  this.adjustMapHeight = function() {
    self._map_elem.css("height", function(){
      return $(window).height() -
      $("#header").outerHeight() -
      $("#crossbar").outerHeight() -
      ( $("#main").outerHeight() - $("#main").height() ) -
      $("#page-header").outerHeight() - 21 + "px"
    });
  },
  
  this.initTree = function(){
    self.tree = self._tree_elem.jstree({
      core      : { html_titles : true },
      plugins   : [ "json_data", "themes", "checkbox"],
      themes    : { theme : "apple", url : "../stylesheets/jstree-apple/style.css", icons : false },
      json_data : { ajax : {
        url : window.location.pathname,
        dataType : "json", 
        success : function(data) {
          self._data = data;
          
          self.positionMarkers();
          self.createNodeListeners();

          window.setTimeout(function(){
            self._tree_elem.jstree("open_all", -1);
            self._tree_elem.jstree("check_all");
            $('#' + tree_id + ' li[rel="device"]').each(function() {
              if (!self.wasSelected($(this).data().id) ||
                  $(this).find(".inactive").length) {
                self._tree_elem.jstree("uncheck_node", this);
                self.markers[$(this).data().id].setMap(null);
              }
            });            
            $('#' + tree_id + ' li[rel="device_pool"], #' + tree_id + ' li[rel="provider"]').each(function() {
              if (!$(this).find(".jstree-checked").length)
                self._tree_elem.jstree("close_node", this, true);
            });
          }, 1);
        }        
      } }
    });
  },
  
  this.positionMarkers = function() {
    if ( self.markers.length < 1 ) self.initMarkers();
    else self.updateMarkers();
  },
  
  this.initMarkers = function(){
    $.each(self._data, function(){
      $.each(this.children, function(){
        var device_pool = this;
        $.each(device_pool.children, function(){
          self.createMarker(device_pool, this);
        })
      })
    });
  }, 
  
  this.updateMarkers = function() {
    $.each(self._data, function(){
      $.each(this.children, function(){
        var device_pool = this;
        $.each(device_pool.children, function(){
          var marker = self.markers[this.metadata.id];
          if (marker) {
            marker.setPosition( new google.maps.LatLng( this.metadata.lat, this.metadata.lng ) );
            marker.html = self._marker_html(this.metadata);
            marker.setMap((this.metadata.active ? self.map : null));
          } else self.createMarker(device_pool, this);
        });
      });
    });
  },
  
  this.createMarker = function(device_pool, device) {
    var marker = new StyledMarker({
      styleIcon : new StyledIcon( StyledIconTypes.MARKER, { color : device_pool.attr["data-color"] } ),
      position  : new google.maps.LatLng( device.metadata.lat, device.metadata.lng ),
      map       : (device.metadata.active ? self.map : null)
    });
    
    marker.html = self._marker_html(device.metadata);
    
    self.markers[device.metadata.id] = marker;
    google.maps.event.addListener(marker,"click",function(){
      self._open_window_for_marker(marker);
    });

    return marker;
  },
  
  this._marker_html = function(device) {
    return '<div class="marker_detail">\
      <h2>' + device.name + '</h2>\
      <h3>' + device.status + '</h3>\
      <h4>Updated: ' + device.posted_at + '</h4>\
    </div>';
  },
  
  this._open_window_for_marker = function(marker) {
    self._infoWindow.setContent(marker.html);
    self._infoWindow.open(self.map, marker);
  },
  
  
  this._resetRefreshTimer = function() {
    self._timeout = window.clearTimeout( self._timeout );
    self._timeout = window.setTimeout( self.refresh, 120000 );
  },
  
  this.refresh = function() {
    self._resetRefreshTimer();
    self._infoWindow.close();
    self._tree_elem.jstree("refresh");
  },
  
  this.uncheckNode = function(node){
    self._tree_elem.jstree("uncheck_node", node );
  },
  
  this.checkNode = function(node){
    self._tree_elem.jstree("check_node", node );
  },
    
  this.createNodeListeners = function(){   
    // Driver name click   
    self._tree_elem.delegate("a", "click.jstree", function(e) { 
      // Only handle clicks on the name, and not the inner checkbox element
      if (!$(e.target).is("a")) {
        return;
      }
      // Markers that aren't shown shouldn't be clickable
      var node = $(this).parents("li").first();
      if (!node.hasClass("jstree-checked")) {
        return;
      }
      // Show the detail window
      if (node.data().lat) { // it's a marker
        var marker = self.markers[node.data().id];
        self.map.setCenter( marker.getPosition() );
        self._open_window_for_marker( marker );
        e.stopImmediatePropagation();
      }
    });
    
    // Checkbox toggle events
    self._tree_elem.bind("change_state.jstree", function(e, d) {
      var tagName = d.args[0].tagName;
      console.log(tagName);
      var refreshing = d.inst.data.core.refreshing;
      if (refreshing == true && refreshing == "undefined") {
        return;
      }
      if (tagName == "INS") {
        var node = d.rslt;
        self.updateSelection();
        if (node.data().lat) {
          // Individual marker toggle
          if (node.hasClass("jstree-checked"))
            return self.showMarkers( [self.markers[node.data().id.toString()]] );
          else
            return self.hideMarkers( [self.markers[node.data().id.toString()]] );
        } else {
          // Parent node toggle
          $.each( node.find("[rel=device]"), function(){
            if (node.hasClass("jstree-checked"))
              return self.showMarkers( [self.markers[$(this).data().id.toString()]] );
            else
              return self.hideMarkers( [self.markers[$(this).data().id.toString()]] );
          });
        }
      }
    });
  },

  // Remember selected checkboxes for later
  this.updateSelection = function() {
    var selected = localStorage.getItem("selected_markers");
    if (selected) {
      selected = selected.split(" ");
    } else {
      selected = new Array();
    }
    $('#' + tree_id + ' li[rel="device"]').each(function() {
      var checked = $(this).hasClass("jstree-checked");
      var id = $(this).data().id.toString();
      if (checked && selected.indexOf(id) == -1) {
        selected.push(id);
      } else if (!checked) {
        var index = selected.indexOf(id);
        while (index != -1) {
          selected.splice(index, 1);
          index = selected.indexOf(id);
        }
      }
    });
    selected = selected.join(" ");
    localStorage.setItem("selected_markers", selected);
  };

  // Default: Select all
  this.wasSelected = function(id) {
    var selected = localStorage.getItem("selected_markers");
    if (selected) {
      selected = selected.split(" ");
    }
    if (selected && selected.indexOf(id.toString()) == -1) {
      return false;
    }
    return true;
  };
  
  this.hideMarkers = function(markers){
    $.each(markers, function(){
      var marker = this;
      marker.setMap(null);
    })
  };
  
  this.showMarkers = function(markers){
    $.each(markers, function(){
      var marker = this;
      marker.setMap(self.map);
    })
  };

  this.locateAddress = function(address) {
    $("#search-spinner").css("visibility", "visible");
    $("#search-message").html("");
    self.clearSearchResult();
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({'address': address}, function(results, status) {
      $("#search-spinner").css("visibility", "hidden");
      if (status == google.maps.GeocoderStatus.OK) {
        self.showSearchResult(results[0]);
        if (results.length > 1) {
          $("#search-message").html("(Additional matches)");
          $("#search-message").css("color", "#0081cc");
          $("#search-message").hover(function() {
            $("#search-message .search-results").show();
          }, function() {
            $("#search-message .search-results").hide();
          });
          self.displaySearchResults(results);
        }
      } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
        $("#search-message").html("No results found.");
        $("#search-message").css("color", "#e5004d");
      } else {
        $("#search-message").html("Unable to locate address: " + status);
        $("#search-message").css("color", "#e5004d");
      }
    });
  };

  this.displaySearchResults = function(results) {
    var div = $('<div class="search-results"></div>');
    $("#search-message").append(div);
    var build_result_node = function(result, i) {
      var node = $('<span class="search-result" id="search-result-' + i + '">' +
                   result.formatted_address + '</span>');
      div.append(node);
      if (i == 0) {
        node.addClass("selected");
      }
      node.click(function() {
        if (node.hasClass("selected")) {
          return;
        }
        $(".search-result").each(function() {
          $(this).removeClass("selected");
        });
        self.showSearchResult(result);
        node.addClass("selected");
      });
    }
    for (var i in results) {
      build_result_node(results[i], i);
    }
    div.hide();
  }

  this.showSearchResult = function(result) {
    self.clearSearchResult();
    self.map.setCenter(result.geometry.location);
    self.search_marker = new google.maps.Marker({
      map: self.map,
      position: result.geometry.location
    });
    self.search_marker.html = '<div class="marker_detail">' +
                              '<h2>Search Result:</h2>' +
                              '<h3>' + result.formatted_address +
                              '</h3></div>';
    google.maps.event.addListener(self.search_marker, "click", function(){
      self._open_window_for_marker(self.search_marker);
    });
    self._open_window_for_marker(self.search_marker);
  };

  this.clearSearchResult = function() {
    if (self.search_marker) {
      self.search_marker.setMap(null);
    }
  };

  this.init(map_id);
}
