#!/bin/sh

DB=hass
CUTOFF=$(date '--date=14 days ago' +"%Y-%m-%dT00:00:00")
ACTION="SELECT last_updated,entity_id"
ACTION="SELECT DISTINCT entity_id"
ACTION="DELETE"

psql $DB <<EOF
$ACTION FROM states
WHERE
NOT (  false
    OR entity_id = 'binary_sensor.boiler_heating_active'
    OR entity_id = 'binary_sensor.boiler_heating_pump'
    OR entity_id = 'number.boiler_heating_temperature'
    OR entity_id = 'sensor.badkamer_humidity'
    OR entity_id = 'sensor.badkamer_temperature'
    OR entity_id = 'sensor.bijkeuken_humidity'
    OR entity_id = 'sensor.bijkeuken_temperature'
    OR entity_id = 'sensor.boiler_current_flow_temperature'
    OR entity_id = 'sensor.bresser51_humidity'
    OR entity_id = 'sensor.bresser51_rain'
    OR entity_id = 'sensor.bresser51_temperature'
    OR entity_id = 'sensor.buiten_humidity'
    OR entity_id = 'sensor.buiten_temperature'
    OR entity_id = 'sensor.energy_consumed'
    OR entity_id = 'sensor.energy_generated'
    OR entity_id = 'sensor.fritz_box_phone_state'
    OR entity_id = 'sensor.dsmr_consumption_gas_delivered'
    OR entity_id = 'sensor.dsmr_reading_electricity_delivered_1'
    OR entity_id = 'sensor.dsmr_reading_electricity_delivered_2'
    OR entity_id = 'sensor.dsmr_reading_electricity_returned_1'
    OR entity_id = 'sensor.dsmr_reading_electricity_returned_2'
    OR entity_id = 'sensor.hal_humidity'
    OR entity_id = 'sensor.hal_temperature'
    OR entity_id = 'sensor.kantoor_humidity'
    OR entity_id = 'sensor.kantoor_temperature'
    OR entity_id = 'sensor.kelder_humidity'
    OR entity_id = 'sensor.kelder_temperature'
    OR entity_id = 'sensor.kruipruimte_humidity'
    OR entity_id = 'sensor.kruipruimte_temperature'
    OR entity_id = 'sensor.openweathermap_humidity'
    OR entity_id = 'sensor.openweathermap_temperature'
    OR entity_id = 'sensor.shelly1l_1_tasmota_analog_temperature'
    OR entity_id = 'sensor.slaapkamer_humidity'
    OR entity_id = 'sensor.slaapkamer_temperature'
    OR entity_id = 'sensor.thermostat_hc1_current_room_temperature'
    OR entity_id = 'sensor.vliering_humidity'
    OR entity_id = 'sensor.vliering_temperature'
    OR entity_id = 'sensor.woonkamer_humidity'
    OR entity_id = 'sensor.woonkamer_temperature'
    OR entity_id = 'sensor.zolder_humidity'
    OR entity_id = 'sensor.zolder_temperature'
    OR entity_id = 'switch.doorbell'
    OR entity_id = 'switch.kelder_ventilator'
)
AND last_updated < '$CUTOFF'; 
EOF

