ascendancy_plus = {}

local player_service_trace = nil

local function check_override_ui(players, player_id)
   if not player_id then
      player_id = _radiant.client.get_player_id()
   end
   
   local client_player = players[player_id]
   if client_player then
      if client_player.kingdom == "ascendancy_plus:kingdoms:ascendancy_plus" then
         _radiant.res.apply_manifest("/ascendancy_plus/ui/manifest.json")
      end
   end
end

local function trace_player_service()
   _radiant.call('stonehearth:get_service', 'player')
      :done(function(r)
         local player_service = r.result
         check_override_ui(player_service:get_data().players)
         player_service_trace = player_service:trace('ascendancy_plus ui change')
               :on_changed(function(o)
                     check_override_ui(player_service:get_data().players)
                  end)
         end)
end

radiant.events.listen(ascendancy_plus, 'radiant:init', function()
   radiant.events.listen(radiant, 'radiant:client:server_ready', function()
         trace_player_service()
      end)
   end)

return ascendancy_plus