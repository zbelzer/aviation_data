totals_map = <<-JS 
  function(row) {
    var identifier = "N" + row.identifier;
    var reference = db.aircraft_references.findOne({aircraft_model_code : row.aircraft_model_code});

    var airworthiness_map = {
      0: 'other',
      1: 'standard',
      2: 'limited',
      3: 'restricted',
      4: 'experimental',
      5: 'provisional',
      6: 'multiple',
      7: 'primary',
      8: 'special_flight_permit',
      9: 'light_sport'
    };

    var type_aircraft_map = {
      0: 'other',
      1: 'glider',
      2: 'balloon',
      3: 'blimp',
      4: 'fixed_wing_single_engine',
      5: 'fixed_wing_multi_engine',
      6: 'rotorcraft',
      7: 'weight_shift_control',
      8: 'powered_parachute',
      9: 'gyroplane'
    }

    var type_engine_map = {
      0: 'none',
      1: 'piston',
      2: 'turboprop',
      3: 'turboshaft',
      4: 'turbojet',
      5: 'turbofan',
      6: 'ramjet',
      7: 'two_cycle',
      8: 'four_cycle'
    }

    var category_map = {
      0: 'other',
      1: 'land',
      2: 'sea',
      3: 'amphibian'
    }

    if (reference != null) {
      emit(row.identifier, 
        {
          identifier: identifier,
          model: reference.model_name,
          type: type_aircraft_map[reference.type_aircraft],
          category: category_map[reference.aircraft_category_code],
          engine_type: type_engine_map[reference.type_engine],
          engines: parseInt(reference.engines),
          seats: parseInt(reference.seats)
        }
      );
    }
  }
JS
MongoMapper.database.add_stored_function('master_map', totals_map)

totals_reduce = <<-JS
  function (k, values) {
    return values[0];
  }
JS
MongoMapper.database.add_stored_function('master_reduce', totals_reduce)

map = "function() { return master_map(this) }"
reduce = "function(k, values) { return master_reduce(k, values) }"
Master.collection.mapreduce(map, reduce, :raw => true, :out => {:merge => "aircrafts"})
