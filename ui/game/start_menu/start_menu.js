App.StonehearthStartMenuView.reopen({
   init: function() {
      var self = this;

      self.menuActions.build_chopping_block = function(){
         self.buildChoppingBlock();
      };

      self._super();

      App.waitForStartMenuLoad().then(() => {
         // this is a call to a global function stored in task_manager.js
         _updateProcessingMeterShown();
      });
   },

   buildChoppingBlock: function() {
      var self = this;

      var tip = App.stonehearthClient.showTip('ascendancy_plus:ui.game.menu.build_menu.items.build_chopping_block.tip_title', 'ascendancy_plus:ui.game.menu.build_menu.items.build_chopping_block.tip_description',
         {i18n: true});

      App.setGameMode('place');
      return App.stonehearthClient._callTool('buildChoppingBlock', function() {
         return radiant.call('stonehearth_ace:place_buildable_entity', 'ascendancy_plus:chopping_block_placement_ghost')
            .done(function(response) {
               radiant.call('radiant:play_sound', {'track' : 'stonehearth:sounds:place_structure'} );
               self.buildChoppingBlock();
            })
            .fail(function(response) {
               App.stonehearthClient.hideTip(tip);
            });
      });
   }
});